From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] IPv6 MIB:ipv6RouterAdvert netlink notification
Date: Thu, 15 Jan 2004 18:10:57 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040115.181057.171336180.yoshfuji@linux-ipv6.org>
References: <20031205145700.120e9e68.davem@redhat.com>
	<200401141552.51424.mashirle@us.ibm.com>
	<20040115005252.6e6f1d81.davem@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com, xma@us.ibm.com, davem@redhat.com
Return-path: <netdev-bounce@oss.sgi.com>
To: mashirle@us.ibm.com
In-Reply-To: <20040115005252.6e6f1d81.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <20040115005252.6e6f1d81.davem@redhat.com> (at Thu, 15 Jan 2004 00:52:52 -0800), "David S. Miller" <davem@redhat.com> says:

> > Once receiving a router advertisement message,
> > a netlink notification event will be created.
> > 
> > This patch is against linux-2.6.1.
> 
> This patch looks fine, except I can't see how RTM_GETRA is used anywhere.
> Even if it will be used by some future change, please remove it until that
> later change is made.

Hmm, why do we need this?  What kind of usage?
I think you can do this in user space by opening raw socket.

--yoshfuji
