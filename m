From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: Re: [PATCH 29/32] rt2x00: dscape compatibilitiy
Date: Fri, 28 Apr 2006 15:43:48 +0200
Message-ID: <200604281543.49360.IvDoorn@gmail.com>
References: <200604280003.19645.IvDoorn@gmail.com> <20060428131237.49dbe6a1@griffin.suse.cz>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart2128519.H7Aczl3F43";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rt2x00-devel@lfcorreia.dyndns.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nproxy.gmail.com ([64.233.182.186]:42793 "EHLO nproxy.gmail.com")
	by vger.kernel.org with ESMTP id S1030402AbWD1Nmj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Apr 2006 09:42:39 -0400
Received: by nproxy.gmail.com with SMTP id x30so1495654nfb
        for <netdev@vger.kernel.org>; Fri, 28 Apr 2006 06:42:38 -0700 (PDT)
To: Jiri Benc <jbenc@suse.cz>
In-Reply-To: <20060428131237.49dbe6a1@griffin.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart2128519.H7Aczl3F43
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Friday 28 April 2006 13:12, Jiri Benc wrote:
> On Fri, 28 Apr 2006 00:03:19 +0200, Ivo van Doorn wrote:
> > Latest dscape patches have broken rt2x00,
> > fix compile issues, and support the new features.
>=20
> > @@ -2466,6 +2568,7 @@ rt2500pci_init_hw(struct rt2x00_pci *rt2
> >  	hw->no_tkip_wmm_hwaccel =3D 1;
> >  	hw->extra_hdr_room =3D 0;
> >  	hw->device_strips_mic =3D 0;
> > +	hw->monitor_during_oper =3D 1;
>=20
> You should not set this to 1 if you support only one interface at a
> time. Please add support for concurrent running of one regular (i.e.
> STA, IBSS, AP, WDS) interface plus arbitrary number of monitor
> interfaces or set monitor_during_oper to 0.
>=20
> (Yes, I know, I definitely must reserve some time to write a
> documentation about monitor mode support.)

My fault, this was a leftover from my initial patch for the dscape update.
I actually had written some code to indeed allow multiple monitor
mode interfaces. But I spotted some problems with it, and removed the code
and planned to rewrite it later after I had send this code series.
I'll create a quick patch to correctly set the monitor_during_oper variable,
because the patch for correct monitor mode behaviour might take some time.

--nextPart2128519.H7Aczl3F43
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQBEUhwVaqndE37Em0gRAuS5AKCl5JZmaJBp7GUQlrSk7rPhW6WHLQCdGoyg
zknnf4mYVStKte/JDhc9wYU=
=05+0
-----END PGP SIGNATURE-----

--nextPart2128519.H7Aczl3F43--
