From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH, TAKE 2] [IPV6] XFRM: extract xfrm_lookup() from
 ip6_dst_lookup() (is Re: [PATCH][IPv6] separation xfrm_lookup from
 ip6_dst_lookup)
Date: Wed, 27 Oct 2004 00:43:59 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041027.004359.62730834.yoshfuji@linux-ipv6.org>
References: <417D6FD0.7010903@hp.com>
	<20041026.125539.84990576.yoshfuji@linux-ipv6.org>
	<417E5F37.4010501@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Brian.Haley@hp.com
In-Reply-To: <417E5F37.4010501@hp.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <417E5F37.4010501@hp.com> (at Tue, 26 Oct 2004 10:29:11 -0400), Brian Haley <Brian.Haley@hp.com> says:

> >>Attached is a patch that fixes that and also brings the rt0_hdr struct 
> >>in-line with RFC 3542 by removing the "bitmap" field.
> > 
> > Good catch but please do not change bitmap.
> 
> I understand that was more cosmetic since it's a kernel header, but can
> you explain it any further?  I couldn't find any other occurences than 
> those I fixed.  The user-space version in netinet/ip6.h is even more 
> broken and I'm pushing that to the glibc people now too.

First, in general, please do not mix two things.

Second, because we're not ready to migrate.
Please do not do that (pushing it to the glibc people) until we're ready.
We really need to do in consistent way; kernel header / glibc header,
and even with other systems.

--yoshfuji
