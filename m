From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: Wifi support for iproute2
Date: Mon, 05 Mar 2007 00:43:16 +0100
Message-ID: <1173051796.6131.18.camel@johannes.berg>
References: <20070304012653.GA9587@hooker.hq.c3d2.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-jzTeR7ObJBC3CaEyCbBO"
Cc: netdev@vger.kernel.org
To: Stephan Maka <stephan@spaceboyz.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:59818 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752518AbXCDXnl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Mar 2007 18:43:41 -0500
In-Reply-To: <20070304012653.GA9587@hooker.hq.c3d2.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-jzTeR7ObJBC3CaEyCbBO
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Sun, 2007-03-04 at 02:26 +0100, Stephan Maka wrote:

> Everyone told me dscape is near, but I hope iwlib will be ported then.

Just a few short notes to add to Stephen's reply. dscape (or mac80211
now, it's been renamed) is going to migrate away from wireless
extensions, in fact, wext is going to loom in the "backward
compatibility" corner. That's quite some time off, but there's no point
in writing new tools for it anyway.

Within the kernel, cfg80211 is (hopefully!) going to replace wext, with
the main userspace API being nl80211 (but some sysfs stuff too.)

If you look at http://git.sipsolutions.net/pynl80211.git/ (usable as
both a git and gitweb url) you'll find a python nl80211 tool I hacked up
for some basic stuff to configure things via nl80211. Most of that
doesn't actually work yet, of course, since mac80211 still uses wext
internally, but as soon as we get enough manpower that'll change.

johannes

--=-jzTeR7ObJBC3CaEyCbBO
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iD8DBQBF61mU/ETPhpq3jKURAgq2AJ0XKcCFSNtjwwBczR5DHM92o90U/gCdF4vo
iDDWEQPTkn3k30JmHVNNvZ4=
=NuPf
-----END PGP SIGNATURE-----

--=-jzTeR7ObJBC3CaEyCbBO--

