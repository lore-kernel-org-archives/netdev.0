From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH, TAKE 2] [IPV6] XFRM: extract xfrm_lookup() from
 ip6_dst_lookup() (is Re: [PATCH][IPv6] separation xfrm_lookup from
 ip6_dst_lookup)
Date: Wed, 27 Oct 2004 09:10:39 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041027.091039.56337914.yoshfuji@linux-ipv6.org>
References: <417E5F37.4010501@hp.com>
	<20041027.004359.62730834.yoshfuji@linux-ipv6.org>
	<417E92D9.1050305@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Brian.Haley@hp.com
In-Reply-To: <417E92D9.1050305@hp.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <417E92D9.1050305@hp.com> (at Tue, 26 Oct 2004 14:09:29 -0400), Brian Haley <Brian.Haley@hp.com> says:

> > Second, because we're not ready to migrate.
> > Please do not do that (pushing it to the glibc people) until we're ready.
> > We really need to do in consistent way; kernel header / glibc header,
> > and even with other systems.
> 
> The kernel struct is the correct size (since addr[0] has no size), 
> ip6_rthdr0 in ip6.h is not, it's 128 bits too big.  Let me know the 
> right steps to go through to correct this and I'll get it done, you can 
> send it off-line if you like.

Because we do not support RFC3542, extra 128bits is definitely correct.

--yoshfuji
