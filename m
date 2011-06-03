From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: bridge/netfilter: regression in 2.6.39.1
Date: Fri, 03 Jun 2011 23:31:10 +0100
Message-ID: <1307140270.22348.114.camel@localhost>
References: <4DE93422.3070000@ahsoftware.de>
	 <1307129642.2600.2.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Alexander Holler <holler@ahsoftware.de>,
	linux-kernel@vger.kernel.org, David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:29725 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756363Ab1FCWbO convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jun 2011 18:31:14 -0400
In-Reply-To: <1307129642.2600.2.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2011-06-03 at 21:34 +0200, Eric Dumazet wrote:
> Le vendredi 03 juin 2011 =C3=A0 21:21 +0200, Alexander Holler a =C3=A9=
crit :
> > Hello,
> >=20
> > I'm getting a oops in the bridge code in br_change_mtu() with 2.6.3=
9.1.=20
> > The patch below seems to fix that.
> >=20
> > I'm not sure about the usage of dst_cow_metrics_generic() in=20
> > fake_dst_ops, but after having a quick look at it seems to be ok to=
 use=20
> > that here.
> >=20
> > Regards,
> >=20
> > Alexander
> >=20
> > -----
> >  From 3c1d5951af73389798afeea672ec224e195b8e8d Mon Sep 17 00:00:00 =
2001
> > From: Alexander Holler <holler@ahsoftware.de>
> > Date: Fri, 3 Jun 2011 20:43:06 +0200
> > Subject: [PATCH] bridge: add dst_cow_metrics_generic to fake_dst_op=
s
> >=20
> > Commit 42923465fb8d025a2b5153f2e7ab1e6e1058bf00 does here what it
> > should prevent, it introduces NULL a dereference.
> >=20
>=20
> I cant find this commit in known trees. Could you give the real commi=
t
> id and its title ?
[...]

It's your commit 33eb9873a283a2076f2b5628813d5365ca420ea9, applied to
2.6.39.

Ben.

--=20
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

