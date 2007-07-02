From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: Fwd: [PATCH] [-mm] ACPI: export ACPI events via netlink
Date: Mon, 02 Jul 2007 16:34:43 +0200
Message-ID: <1183386883.4089.120.camel@johannes.berg>
References: <1179827251.7707.29.camel@localhost.localdomain>
	 <4466a10705270629h31977813hd2fc8330bcd87f78@mail.gmail.com>
	 <4466a10705270634j3560c9a3j9c3630ddc20a24aa@mail.gmail.com>
	 <1181811576.5411.27.camel@localhost.localdomain>
	 <1181820510.4091.9.camel@localhost>
	 <1181869285.5411.39.camel@localhost.localdomain>
	 <1182178882.4063.11.camel@localhost>
	 <1182223964.5411.76.camel@localhost.localdomain>
	 <1182811210.6644.22.camel@johannes.berg>
	 <1182986681.5155.55.camel@localhost>
	 <1183121869.4089.57.camel@johannes.berg>  <468504FE.9000502@trash.net>
	 <1183122920.4089.63.camel@johannes.berg>  <468507C9.2000800@trash.net>
	 <1183124085.4089.66.camel@johannes.berg>  <46850CB8.8000509@trash.net>
	 <1183124981.4089.69.camel@johannes.berg>  <46850EDE.5020804@trash.net>
	 <1183125924.4089.73.camel@johannes.berg>
	 <1183126739.4089.76.camel@johannes.berg>
	 <1183129006.4089.84.camel@johannes.berg>
	 <1183217536.5165.25.camel@localhost>
	 <1183365821.4089.94.camel@johannes.berg>  <4688F612.1060408@trash.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-fzTMNlQU3GC3Z/Ulc/1b"
Cc: hadi@cyberus.ca, Zhang Rui <rui.zhang@intel.com>,
	netdev@vger.kernel.org,
	"linux-acpi@vger" <linux-acpi@vger.kernel.org>, lenb@kernel.org,
	Thomas Graf <tgraf@suug.ch>
To: Patrick McHardy <kaber@trash.net>
Return-path: <linux-acpi-owner@vger.kernel.org>
In-Reply-To: <4688F612.1060408@trash.net>
Sender: linux-acpi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-fzTMNlQU3GC3Z/Ulc/1b
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Mon, 2007-07-02 at 14:56 +0200, Patrick McHardy wrote:

> For information that belongs together logically a struct is fine.

Ok.

> The main reason to use nested attributes is when you only have a
> single attribute to store your data in (for example TCA_OPTIONS
> for qdiscs). In that case a nested attribute should be used to
> allow to extend it in the future. Below that nested attribute
> you could put a struct of course.

Right, but that's not applicable to this unless I'm misunderstanding
you.

> In this case I think using a string attribute instead of a fixed
> sized structure also makes sense for a different reason. Its
> unlikely that groups will really use the maximum name length
> allowed, so it should save some bandwidth.

I suppose if I put (ID,name) into the struct it needn't be fixed-size
length, but I dislike that as well. Do I understand you correctly in
that you prefer the way I did it now?

johannes

--=-fzTMNlQU3GC3Z/Ulc/1b
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iD8DBQBGiQ0D/ETPhpq3jKURAnBMAKCZzcCv7tY1k8LvuVazqB5zY2VrHACfdoth
r64nbmI+vAUGhbjhxg0Pt18=
=m7up
-----END PGP SIGNATURE-----

--=-fzTMNlQU3GC3Z/Ulc/1b--

