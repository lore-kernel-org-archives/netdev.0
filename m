From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 1/2] ip6_gre: Fix MTU setting for ip6gretap
Date: Tue, 24 May 2016 14:34:17 -0700 (PDT)
Message-ID: <20160524.143417.15421952212090108.davem@davemloft.net>
References: <1463825855-7363-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: yanhaishuang@cmss.chinamobile.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1463825855-7363-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
Date: Sat, 21 May 2016 18:17:34 +0800

> When creat an ip6gretap interface with an unreachable route,
> the MTU is about 14 bytes larger than what was needed.
 ...
> Because rt is not NULL here, so dev->mtu will subtract the ethernet
> header length later. But when rt is NULL, it just simply return, so
> dev->mtu doesn't update correctly in this situation.
> 
> This patch first verify the dev->type is ARPHRD_ETHER for ip6gretap
> interface, and then decrease the mtu as early as possible.
> 
> Signed-off-by: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>

Applied.
