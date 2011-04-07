From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH v2 14/16] Intel net drivers: convert to ndo_fix_features
Date: Thu, 07 Apr 2011 08:00:05 -0700
Message-ID: <1302188405.2789.25.camel@jtkirshe-MOBL1>
References: <cover.1295734270.git.mirq-linux@rere.qmqm.pl>
	 <28a1c0f6e1ab9a523ee1e947ca4a013fd5730539.1295734271.git.mirq-linux@rere.qmqm.pl>
	 <AANLkTikYg6x-T42eSh-ou=bJr=16wLxoVYXON5qiyyvu@mail.gmail.com>
	 <20110407125127.GA16755@rere.qmqm.pl>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-PDpgbbyuTFrWcp6AzDKV"
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Ben Hutchings <bhutchings@solarflare.com>
To: =?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:7065 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753765Ab1DGPA0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Apr 2011 11:00:26 -0400
In-Reply-To: <20110407125127.GA16755@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-PDpgbbyuTFrWcp6AzDKV
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2011-04-07 at 05:51 -0700, Micha=C5=82 Miros=C5=82aw wrote:
> On Wed, Jan 26, 2011 at 01:47:46AM -0800, Jeff Kirsher wrote:
> > 2011/1/22 Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>:
> > > Private rx_csum flags are now duplicate of netdev->features & NETIF_F=
_RXCSUM.
> > > Removing this needs deeper surgery.
> > >
> > > Since ixgbevf doesn't change hardware state on RX csum enable/disable
> > > its reset is avoided.
> > >
> > > Things noticed:
> > >  - e1000, e1000e and ixgb have RX csum disabled by default
> > >  - HW VLAN acceleration probably can be toggled, but it's left as is
> > >  - the resets on RX csum offload change can probably be avoided
> > >  - there is A LOT of copy-and-pasted code here
> [...]
> > Upon initial reviews of the patch, we found issues with the e1000e
> > changes so far.  We are working to put together a patch to resolve the
> > issues (and to do the conversion to ndo_fix_features).  Based on the
> > initial work done by Michal, we can take care of the changes necessary
> > for the Intel Wired Ethernet drivers, and will wait for acceptance of
> > the net and ethtool changes before pushing the Intel patch.  Is that
> > acceptable?
> >=20
> > For e1000e, this patch breaks the ability to manually override the
> > default behavior of disabling TSO for 10/100, and there is some
> > additional cleanup that can be done w.r.t. Rx csum flags.
>=20
> I resent other patches after the ethtool changes got it 2.6.39-rc, but sk=
ipped
> this one based on your mail. Do you want me to resend parts not relevant
> to e1000e or can I drop it altogether from my queue?
>=20
> Best Regards,
> Micha=C5=82 Miros=C5=82aw

You can drop them from your queue.  We have been working on these
patches.  We found other issues with the other drivers as well, so we
are making the appropriate changes to get this conversion completed.

Thanks Michal.

Cheers,
Jeff

--=-PDpgbbyuTFrWcp6AzDKV
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAABAgAGBQJNndF1AAoJECTsCADr/EWUeK4H/0qGE+MaKKeVfO2yMYrHeiFQ
AsfPTssgsTdiI8AYp+2HHi4t7BZM9Qivhq15c6Fo6RtlG6Ki2VtEt8ASCYYyHkkm
CkqAPrVaLELmGUPPpy3vhQlIOxTdIW5TUNWFbb0XIAG5H2qrBPCO2ScXHYnYDTAz
yEe1VqqkcEl7YdQK0hx9WVRwF0CQCK+q9GGG62ItFxCwztR7wtySi6B0+w2RBDY8
Rtao9amLa0OC/tquUoM1A1RgckSzorFBxjXL/auvyqmz9WhkwjFruG13eLRIa1Vi
+oBUV4iBTVfMbsToePLC8xlKD4/eIYgGun4s4w5Padpa3fxA0TILBp4TR+W1a9E=
=hczL
-----END PGP SIGNATURE-----

--=-PDpgbbyuTFrWcp6AzDKV--

