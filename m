From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [RFC v2] mac80211: assign needed_headroom/tailroom for netdevs
Date: Mon, 05 May 2008 21:57:36 +0200
Message-ID: <1210017456.4181.23.camel@johannes.berg>
References: <1210010254.4181.4.camel@johannes.berg>
	 <20080505.115855.137964071.davem@davemloft.net>
	 <1210014316.4181.14.camel@johannes.berg>
	 <20080505.125013.129139559.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-20aGgLRMqfAipAY4HMzi"
Cc: tomasw@gmail.com, linville@tuxdriver.com, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:47993 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760303AbYEET6j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 May 2008 15:58:39 -0400
In-Reply-To: <20080505.125013.129139559.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-20aGgLRMqfAipAY4HMzi
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


> My bad, it merely allows for devices that can handle
> frag lists in sk_buff as transmit packets.

:)

> I guess you could use this, btw, to take on arbitrary things
> to the front of frames to handle big headers.  But that's more
> expensive than just getting the LL header length right.

Not necessarily because we seem to be getting a lot of cloned frames
that we need to copy all the time. If we would remove the ethernet
header and stick that skb into the fraglist of a new skb we'd win.

johannes

--=-20aGgLRMqfAipAY4HMzi
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIVAwUASB9mr6Vg1VMiehFYAQJjpw//Rl2TGzXcriQYbaWeFB9lfpioDyBpGPbw
HvAvqDkK4/bgMhfkCkygk3TmnSgVl4hSC21mekK1eUUdyMEPPohs7iNYXikhnrvP
e99JWYhoa1KqTDsNqPaZ4i4Xzl6fSMPxBU9Q/sPxhQqTMHd48k7no/hol7xLMr6V
hlvumxgCE13yPUNjVCMBz+faoXxQ7aJHQ0TnFbom/Kmn2vcw67PUnnnplcnlP29+
Qj7C69cqX+ggfhzE9QtDt0KjS71Sd5ZrMkkxilTpIgi5KSNBW779sVJdUTGiTlzg
k2jlBV9nEUCuh5hYKwiq6x8WSq4jM0SH6v7hGXTErDQsMDGeloxrfO6u0zLL8g5h
PJkuAYGPEcbasr5wFtSUP4cUjNmPQKE52aqAcx0GuIGmZE/G4r+zlG5AdgcB9DgW
XPeysxRNfrSy2iiynvGyGPnOhieBCLcg0zXDcu/u5W8KSLlRX+x/ylfnEUXBt9dO
XGAH6nR8raKlEzghYGzrCEVw5Nh1Nf1gQ7d3cozNV3ri2lY340v3bWwOFAPfx0SU
4vt8aivjuTqnHqtBsFSk+vEcqnlmL/UuJwafj5WMO7bTtdUVApWFIXTIuOKQAbqm
Teqzk2ESbmG42MTwjUhnRRAnHR0Nws8DGIKUVQvMJRI7v+YdV2e94+jo6WKxJ6kW
9l3x483Fvxw=
=oAco
-----END PGP SIGNATURE-----

--=-20aGgLRMqfAipAY4HMzi--

