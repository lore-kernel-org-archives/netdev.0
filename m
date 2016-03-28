From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] openvswitch: Use proper buffer size in nla_memcpy
Date: Mon, 28 Mar 2016 11:39:05 -0400 (EDT)
Message-ID: <20160328.113905.1872357343182915465.davem@davemloft.net>
References: <1459159739-51541-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pshelar@nicira.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, dev@openvswitch.org
To: yanhaishuang@cmss.chinamobile.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1459159739-51541-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
Date: Mon, 28 Mar 2016 18:08:59 +0800

> For the input parameter count, it's better to use the size
> of destination buffer size, as nla_memcpy would take into
> account the length of the source netlink attribute when
> a data is copied from an attribute.
> 
> Signed-off-by: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>

Applied, thanks.
