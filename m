From: Florian Lohoff <flo@rfc822.org>
Subject: Re: capturing VLAN
Date: Fri, 29 Feb 2008 11:22:09 +0100
Message-ID: <20080229102209.GC15289@paradigm.rfc822.org>
References: <200802290956.19093.krauz@cncz.cz>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="V88s5gaDVPzZ0KCq"
Cc: netdev@vger.kernel.org
To: Pavel Krauz <krauz@cncz.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hydra.gt.owl.de ([195.71.99.218]:36064 "EHLO hydra.gt.owl.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758690AbYB2KzI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Feb 2008 05:55:08 -0500
Content-Disposition: inline
In-Reply-To: <200802290956.19093.krauz@cncz.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--V88s5gaDVPzZ0KCq
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, Feb 29, 2008 at 09:56:18AM +0100, Pavel Krauz wrote:
> Hi guys
> as I see it, capturing packets with VLAN tag over PCAP is simply
> broken on 2.6 kernel with the HW acceleration. Applications that need
> unmodified packets over PCAP in promisc mode cannot work when VLAN
> is present in the traffic.

Older kernels (e.g. debian 2.6.18) had the problem that when you enable
802.1q VLAN support the acenic driver dropped the first vlan tag on a
packet regardless if you enable vlans or not. If you recompile a kernel
without 802.1q VLAN support all 802.1q tags should be in the pcap.

I was dumping 802.1qinq with 2 VLAN tags stacked and the outer tag
was gone ...

Without looking at all the drivers there is definitly something
driver and config option dependent when capturing 802.1q traffic.

Flo
--=20
Florian Lohoff                  flo@rfc822.org             +49-171-2280134
	Those who would give up a little freedom to get a little=20
          security shall soon have neither - Benjamin Franklin

--V88s5gaDVPzZ0KCq
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQFHx9zRUaz2rXW+gJcRAoPoAJ42DKwBgWPrnJ+s10SODhr6JnmJYwCcCaif
E+ahYO9te2FDErSG7e9ijrE=
=1JIE
-----END PGP SIGNATURE-----

--V88s5gaDVPzZ0KCq--
