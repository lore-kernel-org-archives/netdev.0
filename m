From: Brian Haley <Brian.Haley@hp.com>
Subject: Re: [PATCH, TAKE 2] [IPV6] XFRM: extract xfrm_lookup() from ip6_dst_lookup()
 (is Re: [PATCH][IPv6] separation xfrm_lookup from ip6_dst_lookup)
Date: Tue, 26 Oct 2004 10:29:11 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <417E5F37.4010501@hp.com>
References: <20040801195135.16734846.davem@redhat.com>	<20040828.014935.131415609.yoshfuji@linux-ipv6.org>	<417D6FD0.7010903@hp.com> <20041026.125539.84990576.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: quoted-printable
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: yoshfuji@linux-ipv6.org
In-Reply-To: <20041026.125539.84990576.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


YOSHIFUJI Hideaki / =E5=90=89=E8=97=A4=E8=8B=B1=E6=98=8E wrote:

>>Attached is a patch that fixes that and also brings the rt0_hdr struct=20
>>in-line with RFC 3542 by removing the "bitmap" field.
>=20
> Good catch but please do not change bitmap.

I understand that was more cosmetic since it's a kernel header, but can
you explain it any further?  I couldn't find any other occurences than=20
those I fixed.  The user-space version in netinet/ip6.h is even more=20
broken and I'm pushing that to the glibc people now too.

Thanks,

-Brian
