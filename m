From: =?iso-8859-15?Q?Beno=EEt?= Vaillant <benoit.vaillant@no-log.org>
Subject: Re: sd8686 linux system hang: not always
Date: Sat, 22 Aug 2009 00:55:50 +0200
Message-ID: <20090821225550.GA1634@kaos.fbx.proxad.net>
References: <20090819185605.GA19345@kaos.fbx.proxad.net>
 <1250710797.5351.89.camel@localhost.localdomain>
 <20090820204051.GA24491@kaos.fbx.proxad.net>
 <1250859856.2876.11.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="a8Wt8u1KmwUX3Y2C"
Cc: =?iso-8859-15?Q?Beno=EEt?= Vaillant <benoit.vaillant@no-log.org>,
	netdev@vger.kernel.org
To: Dan Williams <dcbw@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp6-g21.free.fr ([212.27.42.6]:55436 "EHLO smtp6-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932617AbZHUWz2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Aug 2009 18:55:28 -0400
Content-Disposition: inline
In-Reply-To: <1250859856.2876.11.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--a8Wt8u1KmwUX3Y2C
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi,

On Fri, Aug 21, 2009 at 08:04:16AM -0500, Dan Williams wrote:
> Well, besides the fact that the Poulsbo SDHC driver hasn't actually
> passed review for the kernel yet...=20

And other parts of Poulsbo drivers were removed from -at least-
debian, for the xorg part of it. I had that in mind.

> That doesn't mean the Poulsbo driver isn't a fine driver, but if
> Pierre hasn't acked it, I don't really trust it.  The largest # of
> problems people have had with Libertas SDIO have been with the host
> controller with things like transfer widths, clocking, interrupt
> vs. polled mode, chunk size, etc.  When the SDHC driver and hardware
> they are using actually starts working well, then libertas actually
> starts working well.

Ok. I'll check on parameters when I get spare time. I did consider
such things could be part (all? :) ) of the issue.

Pointers welcomed, if any other than browsing the web!

> So I don't mean to brush you off, but we know the chip works pretty well
> with the Ricoh line (which I'm typing this on right now with an sd8686)
> and a few other embedded-type controllers.  So I'd start diving down
> into the SDHC driver code for Poulsbo and try to figure out what's going
> on there and in the MMC layer.

Hehe, no worry, I know the chip works fine under midinux. Yet
compiling such working drivers would either lead me to revert to an
older kernel version (and not provide testing with newer ones, thus)
or adapt the marvell driver to newer kernel, task which I'm rather not
sure to be able to carry by some quite good amount of time :)

You didn't brush me off, I wasn't expecting a straight working
solution :)

TFYA,

--=20
Beno=EEt

--a8Wt8u1KmwUX3Y2C
Content-Type: application/pgp-signature; name="~/.gnupg/public_key.txt"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEARECAAYFAkqPJfYACgkQqNn0jQsEC2bwCgCeOWNfnCQD0lXVEyFeAk868pem
aLEAn1cB5ujfeBwp/AzVqiVZMF0pXDqa
=yM+X
-----END PGP SIGNATURE-----

--a8Wt8u1KmwUX3Y2C--
