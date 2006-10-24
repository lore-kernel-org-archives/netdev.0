From: Michael Wu <flamingice@sourmilk.net>
Subject: Re: [RFC] [PATCH 0/3] Add Regulatory Domain support to d80211
Date: Tue, 24 Oct 2006 18:52:52 -0400
Message-ID: <200610241853.03135.flamingice@sourmilk.net>
References: <20061024140212.GB17543@devicescape.com> <C86180A8C204554D8A3323D8F6B0A29F018523A5@dhost002-46.dex002.intermedia.net> <43e72e890610241503r692975dfx65b2eab987ffbb3d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart17605571.cZ7oibVg2U";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: "Simon Barber" <simon@devicescape.com>,
	"David Kimdon" <david.kimdon@devicescape.com>,
	netdev@vger.kernel.org, "Jiri Benc" <jbenc@suse.cz>,
	"John W. Linville" <linville@tuxdriver.com>,
	"Jean Tourrilhes" <jt@hpl.hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.rutgers.edu ([128.6.72.243]:64668 "EHLO
	annwn14.rutgers.edu") by vger.kernel.org with ESMTP
	id S1422767AbWJXWyG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Oct 2006 18:54:06 -0400
To: "Luis R. Rodriguez" <mcgrof@gmail.com>
In-Reply-To: <43e72e890610241503r692975dfx65b2eab987ffbb3d@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart17605571.cZ7oibVg2U
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Tuesday 24 October 2006 18:03, Luis R. Rodriguez wrote:
> 1. Anyone working on completing FullMAC support on d80211?
That doesn't really make sense. Fullmac devices should just use WE or cfg80=
211=20
because they, for the most part, do what d80211 does in firmware. There are=
=20
also strange hybrid devices like ipw2100/ipw2200, but IMHO, it's not worth=
=20
trying to bolt d80211 onto those devices unless saner firmware becomes=20
available.

> 2. Who's working on a userspace MLME replacement for d80211 and where
> are we with that?
I think HostAP can handle authentication/association.. or was it=20
wpa-supplicant? Maybe both..

> 3. Who's doing the endianness/smp testing of d80211 and how far are we
> with that?
The endianness issues seemed fine the last time I checked, and people do se=
em=20
to be testing BE enough that to uncover an endianness regression I introduc=
ed=20
when converting WEP code to use crypto api. As for SMP/locking, I think Jir=
i=20
Benc knows how to deal with this.

>
> Lastly, as I have said in previous e-mails -- I agree with a userspace
> daemon but where is it and how long before its ready.. also it may be
> difficult to introduce as a requirement for distributions and for this
> reason I am suggesting going with in-kernel regulatory domain control
> and now perhaps in-kernel MLME for a first stable push of d80211,
> specially since only... 3 in-kernel drivers currently use d80211!
>
4 once p54 is merged, and more to come as I get to them.

/me pokes Linville.

I think time working on the in-kernel MLME is well worth it since I would l=
ike=20
softmac drivers to have feature parity with fullmac drivers. Anything beyon=
d=20
that can go to userspace as far as I'm concerned. (so transitioning to d802=
11=20
based drivers won't involve too much pain unless you really want to take=20
advantage of new features)

Having some basic regulatory domain control in d80211 in the kernel should =
be=20
okay for now just to make sure all drivers like the api presented. Working=
=20
out the details of how to move the d80211 side stuff to userspace should be=
=20
orthogonal to the driver interface and can be dealt with later, IMHO.=20

=2DMichael Wu

--nextPart17605571.cZ7oibVg2U
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQBFPplOT3Oqt9AH4aERAluGAJ9Sl+ogeSQ13RBC0/GpI+tJ1GbofgCfRh8y
klRBc2uojemOkUGZslZWJjc=
=uoGk
-----END PGP SIGNATURE-----

--nextPart17605571.cZ7oibVg2U--
