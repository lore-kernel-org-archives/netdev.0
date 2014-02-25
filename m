From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH net-next] xfrm: Correctly parse netlink msg from 32bits
 ip command on 64bits host
Date: Tue, 25 Feb 2014 12:53:39 +0100
Message-ID: <20140225115339.GK32371@secunet.com>
References: <1392801176-2656-1-git-send-email-fan.du@windriver.com>
 <20140220095934.GF32371@secunet.com>
 <530C3B07.3090406@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Fan Du <fan.du@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:58490 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751344AbaBYLxn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Feb 2014 06:53:43 -0500
Content-Disposition: inline
In-Reply-To: <530C3B07.3090406@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 25, 2014 at 02:41:11PM +0800, Fan Du wrote:
>=20
>=20
> On 2014=E5=B9=B402=E6=9C=8820=E6=97=A5 17:59, Steffen Klassert wrote:
> >For now I think we should just refuse to do anything if someone trie=
s
> >to configure ipsec with 32 bit tools on a 64 bit machine.
>=20
> I'm fine with your point, and it would be a good choice to inform use=
r about
> this behavior other than just creating non-working SA and SP for user=
=2E
>=20
>=20
> From 873812ec0fe8738f476de58a217e58ec47665180 Mon Sep 17 00:00:00 200=
1
> From: Fan Du <fan.du@windriver.com>
> Date: Tue, 25 Feb 2014 14:34:41 +0800
> Subject: [PATCH net-next] xfrm: Do not parse 32bits compiled xfrm net=
link msg on
>  64bits host
>=20
> structure like xfrm_usersa_info or xfrm_userpolicy_info has different=
 sizeof
> when compiled as 32bits and 64bits due to not appending pack attribut=
e in
> their definition. This will result in broken SA and SP information wh=
en user
> trying to configure them through netlink interface.
>=20
> Before forging a compatibility layer like we have it for system calls=
 to map
> this correct. Inform user land about this situation instead of keepin=
g silent,
> then the upper test scripts could behave accordingly.
>=20
> Signed-off-by: Fan Du <fan.du@windriver.com>

I'm ok with your patch, but it does not apply to ipsec-next.
Please rebase to ipsec-next current and resend.

Thanks!
