From: Antoine Tenart <antoine.tenart@free-electrons.com>
Subject: Re: [PATCH 7/9] net: mvmdio: add xmdio support
Date: Wed, 7 Jun 2017 18:13:33 +0200
Message-ID: <20170607161333.GA22888@kwain>
References: <20170607083810.30922-1-antoine.tenart@free-electrons.com>
 <20170607083810.30922-8-antoine.tenart@free-electrons.com>
 <e423ea96-12df-6a19-ce94-149ace2e2272@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
        protocol="application/pgp-signature"; boundary="EeQfGwPcQSOJBaQU"
Cc: Antoine Tenart <antoine.tenart@free-electrons.com>,
        davem@davemloft.net, jason@lakedaemon.net, andrew@lunn.ch,
        gregory.clement@free-electrons.com,
        sebastian.hesselbarth@gmail.com,
        thomas.petazzoni@free-electrons.com, mw@semihalf.com,
        linux@armlinux.org.uk, netdev@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([62.4.15.54]:50203 "EHLO
        mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751734AbdFGQNf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Jun 2017 12:13:35 -0400
Content-Disposition: inline
In-Reply-To: <e423ea96-12df-6a19-ce94-149ace2e2272@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--EeQfGwPcQSOJBaQU
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Florian,

On Wed, Jun 07, 2017 at 08:48:06AM -0700, Florian Fainelli wrote:
> On 06/07/2017 01:38 AM, Antoine Tenart wrote:
>=20
> > +	if (of_device_is_compatible(np, "marvell,orion-mdio")) {
> > +		ops->is_done =3D smi_is_done;
> > +		ops->is_read_valid =3D smi_is_read_valid;
> > +		ops->start_read =3D smi_start_read_op;
> > +		ops->read =3D smi_read_op;
> > +		ops->write =3D smi_write_op;
> > +
> > +		dev->poll_interval_min =3D MVMDIO_SMI_POLL_INTERVAL_MIN;
> > +		dev->poll_interval_max =3D MVMDIO_SMI_POLL_INTERVAL_MAX;
> > +	} else if (of_device_is_compatible(np, "marvell,xmdio")) {
> > +		ops->is_done =3D xsmi_is_done;
> > +		ops->is_read_valid =3D xsmi_is_read_valid;
> > +		ops->start_read =3D xsmi_start_read_op;
> > +		ops->read =3D xsmi_read_op;
> > +		ops->write =3D xsmi_write_op;
> > +
> > +		dev->poll_interval_min =3D MVMDIO_XSMI_POLL_INTERVAL_MIN;
> > +		dev->poll_interval_max =3D MVMDIO_XSMI_POLL_INTERVAL_MAX;
> > +	} else {
> > +		return -EINVAL;
> > +	}
>=20
> Instead of doing this, you could have the ops structure declared e.g: a
> static global variables in the driver and reference them from the
> of_device_id .data field, something like:

Good idea, I'll update the series using static global variables for ops
and poll intervals and reference them in the .data field.

Thanks!
Antoine

--=20
Antoine T=E9nart, Free Electrons
Embedded Linux and Kernel engineering
http://free-electrons.com

--EeQfGwPcQSOJBaQU
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJZOCYsAAoJEFxNi8it27zYrcYP/RON/jrb/gW/jGSu2qGcdHRt
tL0QHU1L/OBTJwRUPJoPR5SOWztEaYvfSjTqu7Dc1KnrnDr68Tvau37b9rbSNBgO
ZNJV4Mb2fKotKSvfT2FwJgPSc/rlxHld8sv6b8QeS4kuiQT/9DxzqNa82vgtBcxp
9rFnhqYvv09NPCSQvoZTfFXmKwEfjtrsGN98Mq5xQKmFLqwOBveWj0FjvwwNBeOL
3pKAnknXFx2qp+iz9McaU3KJs5Bcnl7LJ72Wib4RUs/S7p/W0eml25TFr9ka9KtQ
O2UebQbshLVoAtV7rEFZpDOCoOQjgpziZ4ymcCDK1l2n9NZ7bozwOXA6nZ4SyCn+
DIskel+yMtsCQpjjEaCTxyFUyR1LpJ+1hMcxXnqffTLM/DNjuI/l0J1TuRmY0F5z
MpGaH3L8WEjDi1epdOCG5AgfCTUE7qAQyAvmkZYr8tXZWOUqxdu1qccDEjS+VxfE
IKbOzvwhrujkLJJFWqnCrCIn7DMCTVIzimRnfQTUtS+g56d85icvDaE0NpPlAnFM
PXTR7GHNH7rMG8Ei2ryywwzja9crnovTrRLnL7AzwcEMvN6qws7RAAKgWhPlBOH4
1puj1b6XXZc7N4RwuNSSv89WnNciNJAoAisSBUH4HmZWAzUGN4SRd1+rjP00wzkN
Sk5S0xRsTXArU/zx1Dj6
=xGq6
-----END PGP SIGNATURE-----

--EeQfGwPcQSOJBaQU--
