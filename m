From: Corinna Vinschen <vinschen@redhat.com>
Subject: Re: [PATCH net 3/3] r8169: increase the lifespan of the hardware
 counters dump area.
Date: Wed, 9 Sep 2015 11:00:04 +0200
Message-ID: <20150909090004.GB19913@calimero.vinschen.de>
References: <cover.1441454454.git.romieu@fr.zoreil.com>
 <fb3db9039225ed3a030e779565b8e11f99fc8ae2.1441454454.git.romieu@fr.zoreil.com>
 <20150906103732.GF30539@calimero.vinschen.de>
 <20150907144412.GA26524@calimero.vinschen.de>
 <20150907215251.GA4897@electric-eye.fr.zoreil.com>
 <20150908000202.GA5059@electric-eye.fr.zoreil.com>
 <20150908202315.GH20288@calimero.vinschen.de>
 <20150908232758.GA28427@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="GID0FwUMdk1T2AWN"
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	pomidorabelisima@gmail.com
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-n.franken.de ([193.175.24.27]:48569 "EHLO
	mail-n.franken.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752104AbbIIJAG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Sep 2015 05:00:06 -0400
Content-Disposition: inline
In-Reply-To: <20150908232758.GA28427@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--GID0FwUMdk1T2AWN
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Sep  9 01:27, Francois Romieu wrote:
> Corinna Vinschen <vinschen@redhat.com> :
> [...]
> > - Alternatively I can still reproduce the SEGV in rtl_remove_one
> >   when trying to rmmod the module, I just don't have the stack dump
> >   handy while writing this mail.  I can show it if needed.
>=20
> I see it too.=20
>=20
> > I debugged this on and off the entire day (tweaking, compiling, rebooti=
ng,
> > kernel crash, rinse and repeat).
> >=20
> > And the result of my debugging is totally crazy:
>=20
> My patch corrupts memory.

That's rather obvious, I just fail to see how.

I try to implement this from scratch, maybe I stumble over the cause
by accident...


Corinna

--GID0FwUMdk1T2AWN
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJV7/UTAAoJEPU2Bp2uRE+gEoAP/3MVQoMfRW8dt2xyiL1Z5pR3
eCz4vOU6b9hKQggtJDWdx6+mabsKCgjorjhYA+9S++vbdjjArxCp5IpabDPt2oc4
zttDXRjOu5dGHe0eywBfrKVGRNrYhiiEMKFN0tiYOHeYkiZL3mhKSCaKCiQ13ebF
R/QXq8nu9A8oZG7THp3FmFFR3SnoVpa1c/AWW1YnSXHc5GlxSV/s+ZdwJT0ChETl
Csmcyb4g51u4KmBqDkE6LHc8VW/UXzC5v3NY+BP87oMU+oryAGqC6hUhZtDQ3zbO
9VpyRMEnEJ7LmzFf5UuuhmPs7yboE7SQnNyNhgyENwBHmiRp6O0h74PqxFShe8b+
yHQRNGpMdhF8mDSY7qmnuuucjawSCvusQ4/XS8hpVRraAEQhBTzAWAQy9ca3c0oC
vLxxZVkcZDSxHJs2W4PBhTdBbphcE4SyJlvzGUCtzUVhO9RFr0wMOmznomZ+IpKR
l0LqaaBUyw4d3ZdQCm8EUJdjtl5Vv+8Unfv9q2yv53mBsfrIJPQZkOGzRSNEBHCl
5Cvnbwa5M6I+Rz+pYG8SJHROTldd3U01urw3s6pQmy/O/YWpOfhc339+n0oAeHtE
28JQP0iMZXPeuq31ADTe9bjFCXv3qRF1t4n5sHvat3XCF6Fn/3tJTFvp9V2OJfba
WmhEoDWA0PJRFddr3PnW
=94wp
-----END PGP SIGNATURE-----

--GID0FwUMdk1T2AWN--
