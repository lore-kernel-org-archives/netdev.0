From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] IPv6 MIB:ipv6RouterAdvert netlink notification
Date: Thu, 15 Jan 2004 00:52:52 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040115005252.6e6f1d81.davem@redhat.com>
References: <200311191621.38087.mashirle@us.ibm.com>
	<200312051351.47962.mashirle@us.ibm.com>
	<20031205145700.120e9e68.davem@redhat.com>
	<200401141552.51424.mashirle@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com, xma@us.ibm.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Shirley Ma <mashirle@us.ibm.com>
In-Reply-To: <200401141552.51424.mashirle@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 14 Jan 2004 15:52:51 -0800
Shirley Ma <mashirle@us.ibm.com> wrote:

> Once receiving a router advertisement message,
> a netlink notification event will be created.
> 
> This patch is against linux-2.6.1.

This patch looks fine, except I can't see how RTM_GETRA is used anywhere.
Even if it will be used by some future change, please remove it until that
later change is made.

So please either show where RTM_GETRA is used or regenerate the patch with
that macro definition removed.

Thanks.
