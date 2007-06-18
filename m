From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: wireless userspace MLME and generic netlink vs. multicast
	(was: Re: [Take 2] mac80211 IEEE802.11e/WMM code cleanup)
Date: Mon, 18 Jun 2007 10:46:18 +0200
Message-ID: <1182156378.5924.13.camel@johannes.berg>
References: <20070611085950.GA5540@mail.intel.com>
	 <200706161129.13782.flamingice@sourmilk.net>
	 <1182019869.9058.57.camel@johannes.berg>
	 <200706161516.16447.flamingice@sourmilk.net>
	 <1182081831.23681.29.camel@johannes.berg>
	 <1182132527.4092.90.camel@debian.sh.intel.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-QCboUc+5MAhad1C6Zaxw"
Cc: Michael Wu <flamingice@sourmilk.net>,
	linux-wireless@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>,
	David Lamparter <lists@diac24.net>,
	Thomas Graf <tgraf@suug.ch>, netdev <netdev@vger.kernel.org>
To: Zhu Yi <yi.zhu@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:38759 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754724AbXFRIqH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jun 2007 04:46:07 -0400
In-Reply-To: <1182132527.4092.90.camel@debian.sh.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-QCboUc+5MAhad1C6Zaxw
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Mon, 2007-06-18 at 10:08 +0800, Zhu Yi wrote:

> OK. This is the key of the discussion.

I agree.

> Do we take wpa_supplicant the
> only implementation of userspace MLME or even decision making (ie. DLS
> config) daemon?=20

I think it's a combination of these facts. I don't think DLS decision
making can properly live in wpa_supplicant, it'll need to be integrated
into various multimedia frameworks for example. What Michael is
basically proposing from what I can tell is that all these frameworks
rely on wpa_supplicant's socket-based configuration to tell
wpa_supplicant about it.

> If so, we don't need the API. Otherwise we'd better have
> the API in the kernel because we cannot expect both userspace MLME
> implentation A and B support the same API (via IPC) for configuration.

Exactly. On the one hand I guess you could argue that if the MLME
implementation would be in the kernel there'd only be one as well, but
on the other hand I'd rather be able to have various different MLMEs.
Maybe the xsupplicant project is interested in doing some of this as
well, or maybe some of the various wireless testing tools would like to
be an MLME too under some circumstances...

johannes

--=-QCboUc+5MAhad1C6Zaxw
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iD8DBQBGdkZZ/ETPhpq3jKURArlIAJ48K9m6YyoR5VgxjK1hwmllZAB8swCeIES1
BYsjx+sJKV0QcGiVMoHmMn8=
=ojgq
-----END PGP SIGNATURE-----

--=-QCboUc+5MAhad1C6Zaxw--

