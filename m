From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] ip6_gre: Set flowi6_proto as IPPROTO_GRE in xmit
 path.
Date: Fri, 20 May 2016 10:48:35 -0700 (PDT)
Message-ID: <20160520.104835.678619743450630862.davem@davemloft.net>
References: <1463565952-8781-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
	<1463565952-8781-2-git-send-email-yanhaishuang@cmss.chinamobile.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: yanhaishuang@cmss.chinamobile.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1463565952-8781-2-git-send-email-yanhaishuang@cmss.chinamobile.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
Date: Wed, 18 May 2016 18:05:52 +0800

> In gre6 xmit path, we are sending a GRE packet, so set fl6 proto
> to IPPROTO_GRE properly.
> 
> Signed-off-by: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>

I think it would be a lot better to initialize the flow protocol field
properly in ip6gre_tnl_link_config() instead of fixing it up every
single transmit.
