From: Brian Haley <Brian.Haley@hp.com>
Subject: Re: [PATCH, TAKE 2] [IPV6] XFRM: extract xfrm_lookup() from ip6_dst_lookup()
 (is Re: [PATCH][IPv6] separation xfrm_lookup from ip6_dst_lookup)
Date: Tue, 26 Oct 2004 14:09:29 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <417E92D9.1050305@hp.com>
References: <417D6FD0.7010903@hp.com>	<20041026.125539.84990576.yoshfuji@linux-ipv6.org>	<417E5F37.4010501@hp.com> <20041027.004359.62730834.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: quoted-printable
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: yoshfuji@linux-ipv6.org
In-Reply-To: <20041027.004359.62730834.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


YOSHIFUJI Hideaki / =E5=90=89=E8=97=A4=E8=8B=B1=E6=98=8E wrote:

> First, in general, please do not mix two things.

Sorry, next time I'll split the patch.

> Second, because we're not ready to migrate.
> Please do not do that (pushing it to the glibc people) until we're read=
y.
> We really need to do in consistent way; kernel header / glibc header,
> and even with other systems.

The kernel struct is the correct size (since addr[0] has no size),=20
ip6_rthdr0 in ip6.h is not, it's 128 bits too big.  Let me know the=20
right steps to go through to correct this and I'll get it done, you can=20
send it off-line if you like.

-Brian
