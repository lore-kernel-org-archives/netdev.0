From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: Fwd: [PATCH] [-mm] ACPI: export ACPI events via netlink
Date: Fri, 29 Jun 2007 15:13:00 +0200
Message-ID: <1183122780.4089.60.camel@johannes.berg>
References: <1179827251.7707.29.camel@localhost.localdomain>
	 <1179831825.4121.30.camel@localhost>
	 <1180258853.7707.53.camel@localhost.localdomain>
	 <4466a10705270629h31977813hd2fc8330bcd87f78@mail.gmail.com>
	 <4466a10705270634j3560c9a3j9c3630ddc20a24aa@mail.gmail.com>
	 <1181811576.5411.27.camel@localhost.localdomain>
	 <1181820510.4091.9.camel@localhost>
	 <1181869285.5411.39.camel@localhost.localdomain>
	 <1182178882.4063.11.camel@localhost>
	 <1182223964.5411.76.camel@localhost.localdomain>
	 <1182811210.6644.22.camel@johannes.berg>
	 <1182986681.5155.55.camel@localhost>
	 <1183023939.4769.76.camel@johannes.berg>  <4684F25B.5090607@trash.net>
	 <1183121180.4089.51.camel@johannes.berg>  <4684FF9A.10807@trash.net>
	 <1183122172.5188.24.camel@localhost>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-Kb7Pv1EXJURupg+6UGz/"
Cc: Patrick McHardy <kaber@trash.net>, Zhang Rui <rui.zhang@intel.com>,
	netdev@vger.kernel.org,
	"linux-acpi@vger" <linux-acpi@vger.kernel.org>, lenb@kernel.org,
	Thomas Graf <tgraf@suug.ch>
To: hadi@cyberus.ca
Return-path: <linux-acpi-owner@vger.kernel.org>
In-Reply-To: <1183122172.5188.24.camel@localhost>
Sender: linux-acpi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-Kb7Pv1EXJURupg+6UGz/
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Fri, 2007-06-29 at 09:02 -0400, jamal wrote:

> Maybe a mix (of a few static and mostly dynamic) as Patrick says - but
> that would mean more coding for you ;-> Actually i like the idea of at
> least your ID being your static mcast group and the rest are in the
> dynamic pool (Hey, thanks Patrick;->). This means the first 2^16 are
> static/reserved and if you want more groups, you register for them.

Hah, that means I get to rewrite af_netlink.c to not have a bitmap since
that'd mean that with just a single dynamically registered multicast
group it gets ID 2^16 which means an 8 kilobyte bitmap...

johannes

--=-Kb7Pv1EXJURupg+6UGz/
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iD8DBQBGhQVc/ETPhpq3jKURAjBgAJ9WDQSptwsOLUCvSbtXv6IPNVFNkACePXZQ
x8BQsRNfNjQeMIo2RmIWpBk=
=WFxc
-----END PGP SIGNATURE-----

--=-Kb7Pv1EXJURupg+6UGz/--

