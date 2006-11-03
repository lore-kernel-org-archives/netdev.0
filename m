From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 3/6] d80211: add a perm_addr hardware property
Date: Sat, 04 Nov 2006 00:19:33 +0100
Message-ID: <1162595973.24673.13.camel@johannes.berg>
References: <20061102223854.692274000@sipsolutions.net>
	 <20061102223854.692274000@sipsolutions.net> >
	 <20061102230015.186648000@sipsolutions.net> >
	  <200611031649.32739.flamingice@sourmilk.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-sR/RQ+h/7un3orLCykj8"
Cc: Jiri Benc <jbenc@suse.cz>, netdev@vger.kernel.org,
	Ivo van Doorn <ivdoorn@gmail.com>,
	John Linville <linville@tuxdriver.com>,
	Michael Buesch <mb@bu3sch.de>, Hong Liu <hong.liu@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:19646 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S932291AbWKCXVC
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 Nov 2006 18:21:02 -0500
To: Michael Wu <flamingice@sourmilk.net>
In-Reply-To: <200611031649.32739.flamingice@sourmilk.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-sR/RQ+h/7un3orLCykj8
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Fri, 2006-11-03 at 16:49 -0500, Michael Wu wrote:

> Shouldn't you add something to ieee80211_set_mac_address so the driver/d8=
0211=20
> can find out what MAC address the user actually wants?

Hmm? d80211 already handles the case of the user changing a net_dev's
mac address fine. And it'll tell your driver about it whenever it
matters, at the time the user tries to UP that interface. And other than
that, the driver doesn't care.

> Might be easier to just point perm_addr to dev_addr, but that would make =
it=20
> obvious that perm_addr is a bit messy. A wrapper for drivers that returns=
 a=20
> pointer to dev_addr might be a better idea.

I don't understand this. perm_addr is a field in the ieee80211_hw struct
reflecting the permanent mac address of the card. What's wrong with
that?

> Also, do we need to update interfaces associated with the master interfac=
e=20
> when the master MAC address changes?

No. The interfaces are allowed to have differing mac addresses. But I
think they should all start out with the permanent mac address which is
why I put that field there. I guess you could argue for always using the
master's mac address. I would prefer new devices to start out with the
permanent mac address, but we can change that.

johannes

--=-sR/RQ+h/7un3orLCykj8
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIVAwUARUvOhKVg1VMiehFYAQJvMA//XnjM7LHs8e4ASYrLwmYf0z6zLkPgUphW
7lewa2Jl1JmQPhTE0QYHi3VcmsXzvq1DA8ecv2LYY0RrePj+n5HDQsJmvOd3FQG2
f5xwQwFZ033QYPFf8XwFRUdMZfFubT5DkJDE3HSgXuzrq0Q92xaOzu5m7UMTiVlh
pEH+mEb6HWNED+QIN2SZvvbb+r0akOtIWHKyiU0PzeRHf0CXcSuzSIi51z8OjrKC
uaNhBIvioOjbwTB2ZivQys6o12NrAWs0jq40MBS9dopTm/3bCf7kFbs8f8Vs/z1d
m76erkjGHMaJXCMfTPoLXIu91k+x4QlrfaqKdtaiMGsYqbXQmJ/2ZSEweYFXZ9qZ
HbAvOZDJpH4r8ks5g+0ppOfbRG7W+bpEmGlzsKDSOIl5Ou4Ss2QB+3LHSofSTHCi
4MXUfEuyiAH3HQla8NbQpinI3lPTXsjHVXRDryEDKELlVJny7kQ7VoKrBbXwOpF4
f+ahqTONQ0EayNeHxRbx5U2MVxPw71KeYeBhEGYNYXBIepiv+bXDfYSqSvqkIhHB
xeuoUErrLS8ftNs8uiSby0BUHqYna03HXwpUKmFgnwvaghdWjhkjXf5doBbR1Cxg
IVkwf39wFDRCO2OMaY2pkHMol+xD1+58ykkS0VBU8Yfx2+0W+rr2pKYULOKweK0O
zo9QokjW69s=
=pdxS
-----END PGP SIGNATURE-----

--=-sR/RQ+h/7un3orLCykj8--

