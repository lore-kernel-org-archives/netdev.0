From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: Re: Hardware button support for Wireless cards
Date: Mon, 15 May 2006 23:42:16 +0200
Message-ID: <200605152342.20115.IvDoorn@gmail.com>
References: <!~!UENERkVCMDkAAQACAAAAAAAAAAAAAAAAAC4AAAAAAAAAWMRZS97Em0WybTChcxl4cAEALirLb4lrrkmZC6EvT+GpyAAAAABE9gAAEAAAALs6jNngvN9OooViTUM1CgIBAAAAAA==@serialmonkey.com> <1147720370.3067.14.camel@localhost.localdomain> <20060515194614.GB25683@knob.reflex>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart5631995.qWiWy0ALGg";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: Dan Williams <dcbw@redhat.com>, Michael Buesch <mb@bu3sch.de>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.184]:59993 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S964863AbWEOVka (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 May 2006 17:40:30 -0400
Received: by nf-out-0910.google.com with SMTP id y25so65336nfb
        for <netdev@vger.kernel.org>; Mon, 15 May 2006 14:40:22 -0700 (PDT)
To: Jason Lunz <lunz@falooley.org>
In-Reply-To: <20060515194614.GB25683@knob.reflex>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart5631995.qWiWy0ALGg
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Monday 15 May 2006 21:46, Jason Lunz wrote:
> On Mon, May 15, 2006 at 03:12:50PM -0400, Dan Williams wrote:
> > When those bits get set in the register, is the radio already disabled?
> > ie, for the bcm43xx chip, is it really force-disabled by the button, or
> > does the driver have some control?
>=20
> I assume it disables the radio without any help from the driver, because
> it definitely turns off my radio, but the bcm43xx driver i'm using (in
> 2.6.17-rc4) currently doesn't pay any attention to those registers
> afaik.

Correct, my laptop with an integrated BCM43xx chip works this was as well.
I can use the button to enable and disable the device (led is switching on =
and off)
without a bcm43xx driver installed. Hardware detection just picks it up when
I enable the device with the button as new device. So the hardware button w=
orks
directly with the hardware.

--nextPart5631995.qWiWy0ALGg
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQBEaPW8aqndE37Em0gRArstAKCnDJrnL8uG+uK5bliow6Izzpc76gCfZAQP
ledaZ71puc1dIjLF4BOzU4c=
=Cvj8
-----END PGP SIGNATURE-----

--nextPart5631995.qWiWy0ALGg--
