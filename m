From: Antoine Tenart <antoine.tenart@free-electrons.com>
Subject: Re: [PATCH net-next 10/18] net: mvpp2: use the GoP interrupt for
 link status changes
Date: Wed, 23 Aug 2017 10:25:10 +0200
Message-ID: <20170823082510.GD5202@kwain>
References: <20170724134848.19330-1-antoine.tenart@free-electrons.com>
 <20170724134848.19330-11-antoine.tenart@free-electrons.com>
 <20170726162648.GK12049@lunn.ch>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
        protocol="application/pgp-signature"; boundary="bajzpZikUji1w+G9"
Cc: Antoine Tenart <antoine.tenart@free-electrons.com>,
        davem@davemloft.net, jason@lakedaemon.net,
        gregory.clement@free-electrons.com,
        sebastian.hesselbarth@gmail.com,
        thomas.petazzoni@free-electrons.com, nadavh@marvell.com,
        linux@armlinux.org.uk, mw@semihalf.com, stefanc@marvell.com,
        netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([62.4.15.54]:56981 "EHLO
        mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753486AbdHWIZW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 23 Aug 2017 04:25:22 -0400
Content-Disposition: inline
In-Reply-To: <20170726162648.GK12049@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--bajzpZikUji1w+G9
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Andrew, Russell,

On Wed, Jul 26, 2017 at 06:26:48PM +0200, Andrew Lunn wrote:
> On Mon, Jul 24, 2017 at 03:48:40PM +0200, Antoine Tenart wrote:
> > This patch adds the GoP link interrupt support for when a port isn't
> > connected to a PHY. Because of this the phylib callback is never called
> > and the link status management isn't done. This patch use the GoP link
> > interrupt in such cases to still have a minimal link management. Without
> > this patch ports not connected to a PHY cannot work.
>=20
> When is a GoP link interrupt signalled? When is a port without a PHY
> actually up/down?

When the cable is connected (there is signal) and the serdes is in sync
and AN succeeded.

> With SFF/SFP ports, you generally need a gpio line the fibre module
> can use to indicate if it has link. Fixed-phy has such support, and
> your link_change function will get called when the link changes.

So that would work when using SFP modules but I wonder if the GoP irq
isn't needed when using passive cable, in which case this patch would
still be needed (and of course we should support the new Russell phylib
capabilities).

What's your thoughts on this?

Thanks!
Antoine

--=20
Antoine T=E9nart, Free Electrons
Embedded Linux and Kernel engineering
http://free-electrons.com

--bajzpZikUji1w+G9
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAABCgAdFiEEM7Tg8N8kXOlT7hOhXE2LyK3bvNgFAlmdO+YACgkQXE2LyK3b
vNia5g/+M3syRwE+xZqh9eFInr6Pm0m4w9mftWtLLAH35IJnrxt9ju+rDmA8/GzZ
jOpXeq3kqRfjsQMfSTsrCQBH99sd9l8RAhMJK6lT5LxhaeJZjnqqYteWuSY2ppoi
P92Ba97tvr4EldK10K4rgCLKyKUhgS6zcptfit18RoSF3NKKyiX3ktoeEnsR7DYe
Wuu3ReVA/zsJJAyVjwFVE/wYdjow5m+hFFtqxIVy4xFL+HHFl5ALQxCv44ipFMrV
LyeLSDyJdebSAyc2wMIQfbDE5uZI4YX7Rj0vmvY2NZ7IZAo2Qqpj3o1p/VXv3YYi
Au+7jrSgGcDJz4QpQUYqHhtmYppldq/NVcrRbbMk4KGleWpGRJNa6/tsWjUMO211
yvwS1t3Njrq7Lhv7vAi8Mpk/uUnAO+jyQ11ERCyY/GKd3HlhP6d81TCwUH0atTMU
/bEmCTqGfUzV4MSM5y1UalXyScFnw9xyygFnP1zO3Z9onf9uymCIYthJ5kSZa1va
E23LhP3PsbS4HRNQfE4ONycg+tnq9etPppeqMe0bmzMW+swRUfrvvsfk3at0QvHH
cLpjaomT/ooyg8Tt5pGTfyQsqJvmWZ310HUz/sK8KJPh6VZ5dovdgcWxZ1IwtHhe
bRLQvxlGiaWCVjjv/oOKX1F4YvrVOO2KHGjZldhihuFJmgzeIcg=
=scq5
-----END PGP SIGNATURE-----

--bajzpZikUji1w+G9--
