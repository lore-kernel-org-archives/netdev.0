From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] net: Add etun driver
Date: Tue, 10 Apr 2007 08:18:56 +0200
Message-ID: <1176185936.8459.62.camel@johannes.berg>
References: <m1ps6g5229.fsf@ebiederm.dsl.xmission.com>
	 <1176136628.8459.34.camel@johannes.berg> <461A70A5.8060607@trash.net>
	 <20070409.114402.45491411.davem@davemloft.net>
	 <m1mz1h1guo.fsf@ebiederm.dsl.xmission.com> <461A9DF1.8080904@trash.net>
	 <1176150557.8459.47.camel@johannes.berg> <461AD517.2000906@trash.net>
	 <1176184028.8459.58.camel@johannes.berg>
	 <m1ejmszrpr.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-rcZ7VfZcWcLbXIURBq/X"
Cc: Patrick McHardy <kaber@trash.net>, greearb@candelatech.com,
	containers@lists.osdl.org, shemminger@linux-foundation.org,
	kuznet@ms2.inr.ac.ru, dim@openvz.org, netdev@vger.kernel.org,
	akpm@linux-foundation.org, jgarzik@pobox.com,
	David Miller <davem@davemloft.net>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:60550 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030395AbXDJGSo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Apr 2007 02:18:44 -0400
In-Reply-To: <m1ejmszrpr.fsf@ebiederm.dsl.xmission.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-rcZ7VfZcWcLbXIURBq/X
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Tue, 2007-04-10 at 00:08 -0600, Eric W. Biederman wrote:

> How are you specifying which piece of hardware today?  By interface name?

By wiphy index, which is just the hardware identifier we give each
802.11 device present on the system (if it uses cfg80211)

> What function do your virtual devices serve?

Basically you can have a monitor, access point and WDS link running on
the same 802.11 MAC at the same time and that's what we need to present,
each one as a netdev.

johannes

--=-rcZ7VfZcWcLbXIURBq/X
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iD8DBQBGGyxQ/ETPhpq3jKURAqImAJ4wY8EczYOedDWb827SNry5hFUtSACgkmEG
BuVQJHWf+MGGlD9T7xRQPd4=
=zAGL
-----END PGP SIGNATURE-----

--=-rcZ7VfZcWcLbXIURBq/X--

