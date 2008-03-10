From: Laurent Pinchart <laurentp@cse-semaphore.com>
Subject: Re: [PATCH 6/9] fs_enet: Be an of_platform device when CONFIG_PPC_CPM_NEW_BINDING is set.
Date: Mon, 10 Mar 2008 12:05:08 +0100
Message-ID: <200803101205.16158.laurentp@cse-semaphore.com>
References: <20070920220121.GF28784@loki.buserror.net> <20080307163747.GF10545@ld0162-tx32.am.freescale.net> <1205135421.3837.1.camel@p60365-ste>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart5558490.dEVfZHYD6O";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: Scott Wood <scottwood@freescale.com>, linuxppc-dev@ozlabs.org,
	jgarzik@pobox.com, netdev@vger.kernel.org
To: Sergej Stepanov <Sergej.Stepanov@ids.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailrelay005.isp.belgacom.be ([195.238.6.171]:15502 "EHLO
	mailrelay005.isp.belgacom.be" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751141AbYCJLFT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Mar 2008 07:05:19 -0400
In-Reply-To: <1205135421.3837.1.camel@p60365-ste>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--nextPart5558490.dEVfZHYD6O
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Monday 10 March 2008 08:50, Sergej Stepanov wrote:
> > Acked-by: Scott Wood <scottwood@freescale.com>, if I haven't already.
> >
> > -Scott
>
> I thought, you did it.
> Thank you.

Your documentation patch states that

"The first reg resource is the I/O port register block on which MDIO
resides.  The second reg resource is the I/O port register block on
which MDC resides.  If there is only one reg resource, it is used for
both MDIO and MDC."

If I'm not mistaken the code uses the first reg resource for MDC and the=20
second reg resource for MDIO. Which one should be fixed, the doc or the=20
code ?

Best regards,

=2D-=20
Laurent Pinchart
CSE Semaphore Belgium

Chauss=C3=A9e de Bruxelles, 732A
B-1410 Waterloo
Belgium

T +32 (2) 387 42 59
=46 +32 (2) 387 42 75

--nextPart5558490.dEVfZHYD6O
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.5 (GNU/Linux)

iD8DBQBH1RXs8y9gWxC9vpcRAm3jAJ9EKgr2IrdS69E3pEfa6PKs5z78rACdFA1P
wL54yUPXE1/7gI30qYR0jss=
=rnhD
-----END PGP SIGNATURE-----

--nextPart5558490.dEVfZHYD6O--
