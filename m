From: David Gibson <david@gibson.dropbear.id.au>
Subject: Re: [0/2] netxen: bug fix and diagnostics for possible (hardware?)
 bug
Date: Wed, 18 Dec 2013 17:22:31 +1100
Message-ID: <20131218062231.GB32453@voom.fritz.box>
References: <1387257753-18676-1-git-send-email-david@gibson.dropbear.id.au>
 <31AFFC7280259C4184970ABA9AFE8B938CF85726@avmb3.qlogic.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="mojUlQ0s9EVzWg2t"
Cc: Sony Chacko <sony.chacko@qlogic.com>,
	Rajesh Borundia <rajesh.borundia@qlogic.com>,
	netdev <netdev@vger.kernel.org>,
	"snagarka@redhat.com" <snagarka@redhat.com>,
	"tcamuso@redhat.com" <tcamuso@redhat.com>,
	"vdasgupt@redhat.com" <vdasgupt@redhat.com>
To: Manish Chopra <manish.chopra@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:40212 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750949Ab3LRLOs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Dec 2013 06:14:48 -0500
Content-Disposition: inline
In-Reply-To: <31AFFC7280259C4184970ABA9AFE8B938CF85726@avmb3.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--mojUlQ0s9EVzWg2t
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Dec 17, 2013 at 09:50:52PM +0000, Manish Chopra wrote:
> >-----Original Message-----
> >From: David Gibson [mailto:david@gibson.dropbear.id.au]
> >Sent: Tuesday, December 17, 2013 10:53 AM
> >To: Manish Chopra; Sony Chacko; Rajesh Borundia
> >Cc: netdev; snagarka@redhat.com; tcamuso@redhat.com;
> >vdasgupt@redhat.com
> >Subject: [0/2] netxen: bug fix and diagnostics for possible (hardware?) =
bug
> >
> >At Red Hat, we've hit a couple of customer cases with crashes in the net=
xen driver
> >due to list corruption.  This seems to be very rarely triggered, and unf=
ortunately
> >the dumps we have don't have enough information to be certain of the cau=
se,
> >although we have a possible theory.
> >
> >I'm suggesting, therefore a patch to add some sanity checking which shou=
ld help
> >to at least localize and mitigate the problem when someone hits it in fu=
ture.
> >Please let me know if there's a better approach to doing this.
> >
> >That's 2/2.  1/2 is a fix for a clear bug I spotted along the way, but n=
ot one that
> >could cause the symptoms we've seen.
>=20
> David,
>=20
> Having these checks in data path(Rx path) may have some performance
> impact. It's better to root cause it instead of putting some sanity
> checks.

Obviously, but this was the best way I could think of to try narrowing
down the root cause (at least trying to eliminate driver vs. firmware
bug).

> We will get back to you on this.

If you have a better idea for locating the root cause, please let me
know.  I have access to a vmcore which I can poke around in.

--=20
David Gibson			| I'll have my music baroque, and my code
david AT gibson.dropbear.id.au	| minimalist, thank you.  NOT _the_ _other_
				| _way_ _around_!
http://www.ozlabs.org/~dgibson

--mojUlQ0s9EVzWg2t
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.15 (GNU/Linux)

iQIcBAEBAgAGBQJSsT8nAAoJEGw4ysog2bOS6zgQAIo3vCetmJVxxbMV5MqsAvUe
1g5KzZ9HL+GtC5eTmSkuUGgJZdmO7hrimHzBAoak/6Be9pjWtB5EPr95NDCo5fBi
iZDdtz91C/ej9jmXGAo5Q8ZIoSfxt2+clD6rLERR5wvPJ4WF3QbMpWPtyXcl6/iV
MMyvOpmoxQt03meDQUqPMn6yEN9QXJaSVHoyhEJjrQzUu+8kPImjVMDLAQQGsRDm
zFtyOtstLA2w24MY0EUhke5qAQZ5+D1cgA9cBspEGJn59liwer8FP15h4VDoikAr
3VmLxrUddPEHx+UZsSOjrvJzXVHyKtYc1U5/3urq5R6SioQwjvaZ8xCUIyBV77tt
mlhkQa4mYwp6REudh87NWDE2b/cMukMcb4YH4lVX569i28SV+gZrYmxFwzwmZmke
gSEdY0zfbb5OnW0dw03OQ/KEeRBNEfioiqa+EGpO78LrXOqYyJOYy2XBhCElUtaO
WcUGUnvd6PUSxSALfDH1hNYzB7HHAHbbp57J2NiCSLoP/NRhoH9cwMc5xsTWeDZV
RKihYmOx1gYmOqv2Tku0lxsY5VfFxoayLeUM8sUqOqDseXL8Rch4sTxmyK1q8zfH
nlM2XQWA6X2imZrc1t9A2O4+I+v4INRwLFS+Lw1yNrnh5arZd82OiehJ70Ft+fmy
9WVPbVaXg1MxIyElktvx
=xAHD
-----END PGP SIGNATURE-----

--mojUlQ0s9EVzWg2t--
