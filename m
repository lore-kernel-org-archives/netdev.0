From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [RFC] [PATCH 0/3] Add Regulatory Domain support to d80211
Date: Thu, 26 Oct 2006 00:00:28 +0200
Message-ID: <1161813628.8884.14.camel@johannes.berg>
References: <20061024140212.GB17543@devicescape.com>
	 <C86180A8C204554D8A3323D8F6B0A29F018523A5@dhost002-46.dex002.intermedia.net>
	 <43e72e890610241503r692975dfx65b2eab987ffbb3d@mail.gmail.com>
	 <200610241853.03135.flamingice@sourmilk.net>
	 <43e72e890610251043y22fb9ce6ne5e036dd58f36505@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-+rB8hQbpOIBq5uIwH6Rn"
Cc: Michael Wu <flamingice@sourmilk.net>,
	Simon Barber <simon@devicescape.com>,
	David Kimdon <david.kimdon@devicescape.com>,
	netdev@vger.kernel.org, Jiri Benc <jbenc@suse.cz>,
	"John W. Linville" <linville@tuxdriver.com>,
	Jean Tourrilhes <jt@hpl.hp.com>, Hong Liu <hong.liu@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:32451 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1751215AbWJYWBs
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Oct 2006 18:01:48 -0400
To: "Luis R. Rodriguez" <mcgrof@gmail.com>
In-Reply-To: <43e72e890610251043y22fb9ce6ne5e036dd58f36505@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-+rB8hQbpOIBq5uIwH6Rn
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Wed, 2006-10-25 at 13:43 -0400, Luis R. Rodriguez wrote:

> I guess my hope was that d80211 would just be more than a softmac
> implementation. When I hear wireless stack I don't think "softmac
> implementation", I think a robust set of headers and device
> definitions which all wireless devices can share.

Not just that, a bunch of library functions for example for crypto would
be nice too. That's part of why I've been proposing that the tkip stuff
be library functions that the drivers can call if required, instead of
the bitfields.

Currently, there's lot of top-down stuff in d80211, it does things which
depend on flags and then instructs the driver to do something. This is
good for a bunch of things, but in some cases where devices vary wildly
it may be better to go for library functions instead. IMHO the TKIP key
computation is such a case, it's trivial for a driver to call phase1 and
phase2 when required.

> Also I thought we'd ditch WE as it seems we keep fixing it with gum
> (as seen by Linville's latest ABI compatibility fix).=20

Well, that was sort of necessary.

> If that wasn't
> the case then I'm suggesting it -- can we consider ditching WE?

Well, no. We can make it a second-class citizen like I did with the
cfg80211 work where I made it just one userspace interface for cfg80211
which admittedly sometimes strange behaviour, but it's still there and
current operations should still work with it (and I'd consider not
working a bug except if userspace never calls 'commit' and expects
things to work)

> I'd say lets just go for a
> userspace MLME as its already written but I seriously think we need to
> ditch replace WE first.

It seems no one has a plan on what to do though.

 - Jiri's trying to fix the SMP issues. That's great.
 - Jiri also would like to expand ieee80211_conf.c, the stuff I
   started for cfg80211
 - I'd like to see a header cleanup, it's necessary. Part of the problem
   here is all the sub-ioctl WE foo. Clean that up by moving them into
   cfg80211 as required, there's basically one user, wpa_supplicant (and
   maybe hostapd), screw the others if there are any
 - fix people's minds to not expect a perfect solution immediately but
   accept something that can be expanded on later. I think we need to
   accept some breakage in our development trees to get anywhere at all.

Actually, the last point should be first.

Enough rant from me for today,
johannes

--=-+rB8hQbpOIBq5uIwH6Rn
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIVAwUART/ee6Vg1VMiehFYAQJLPhAAkPp4cV5ZmJrJrUJliXBnkKy5KvLBvWJK
Ewt0aLQbcStuQ0yHf8rGPDGKAyHNnPXz8doVRTBCGn7OzcM2xgTtJjat8FvXaG8E
FPOcrbGbZl+D/vybLZmA4eX/6qEEs4sS7csDZMThzCRl5gxDENJZpFXbXD5lW4wM
CqIRZYo31qWbzCN+mC6UrxzhHcn7dB+MIAd8+bdWazFg7hduQxmBGrK4BsSZ628v
MKA3YjV6Um++zIpQW9aY1H5PTibKeRs1XeaYO/W1i5GxQCaz+treqRsqRpWrbhC6
yhaaEzgQf4MbVcHiHuqBa/5aEmhBombxyWcYU1oPjDUuGqcg146aPr0zu8qA8R8z
w2/YJJu+nA2anz+MFtoYBWR7C5Auziu1laJ7K7sazgZFf57Q4b42J6y0JjN0dz5Z
4sY1rd9FMv+2fMVoNJt5uoY5f8FMJg3JxUSaJjOOKFxt35FmSKFTsVs2mGG4UQFB
plmWF4mB+UkxWgsMVsSNr8TiSzPoNLTRAu+3dtiCb5fhGE/eYdBQh6/JVYw+U72J
g5LkbMAQxfYfiv83gTL2GSdIq2vBDaJULG8kK0Bb0hZvWDdNOfZ262ftuwz/N504
tuvRpOfSpCRTluwNbJnqLy+YWxD5OkRmRmRlK+4YobpL/97ZIxTM7CAi2yxvBO1K
xnFW687jeG0=
=J1/l
-----END PGP SIGNATURE-----

--=-+rB8hQbpOIBq5uIwH6Rn--

