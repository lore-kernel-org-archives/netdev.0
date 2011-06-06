From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [RFC Patch] bonding: move to net/ directory
Date: Mon, 06 Jun 2011 10:31:51 -0700
Message-ID: <1307381511.2698.5741.camel@jtkirshe-linux>
References: <BANLkTimkxi0BofJYv_tRj8Et+OZFu+VfBw@mail.gmail.com>
	 <20110523151336.GF21309@gospo.rdu.redhat.com>
	 <BANLkTikT2HJyGb_4BOF+Ds1AAcJV+HVQ-w@mail.gmail.com>
	 <20110524163323.GB28521@hmsreliant.think-freely.org>
	 <BANLkTinoRXmEAp0mbZdxSmMbntsE-QeRsQ@mail.gmail.com>
	 <20110525152023.GC11867@hmsreliant.think-freely.org>
	 <BANLkTin2HaYjHgGACkwvKwuY-Y_e3+r3JQ@mail.gmail.com>
	 <20110526135053.GB12617@hmsreliant.think-freely.org>
	 <BANLkTikrsr5sZ4aZ5aEmfBSvPE0mEL8g0g@mail.gmail.com>
	 <BANLkTin4VyK3boPqDQnd+Dkv6==cHww9PA@mail.gmail.com>
	 <1307379022.4994.4.camel@Joe-Laptop>
	 <1307379881.3098.71.camel@edumazet-laptop>
	 <1307380827.4994.8.camel@Joe-Laptop>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-ShGNBBPrHtUN8iJlfMWz"
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	=?ISO-8859-1?Q?Am=E9rico?= Wang <xiyou.wangcong@gmail.com>,
	=?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirqus@gmail.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Jay Vosburgh <fubar@us.ibm.com>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:11382 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753514Ab1FFRbw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Jun 2011 13:31:52 -0400
In-Reply-To: <1307380827.4994.8.camel@Joe-Laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-ShGNBBPrHtUN8iJlfMWz
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2011-06-06 at 10:20 -0700, Joe Perches wrote:
> On Mon, 2011-06-06 at 19:04 +0200, Eric Dumazet wrote:
> > Le lundi 06 juin 2011 =C3=A0 09:50 -0700, Joe Perches a =C3=A9crit :
> > > There is a proposal to move some drivers/net content to
> > > drivers/net/sw/
> > > http://vger.kernel.org/netconf2010_slides/netconf-jtk.pdf
> > > I think that'd be fine too.
> > > I believe Jeff is going to submit patches soonish.
> > > http://comments.gmane.org/gmane.linux.network/197232
> > As long as the re-organization is done without loosing "git blame"
> > information on current files, I am fine.
> > If not, this is a showstopper and not worth the pain, exactly like othe=
r
> > cleanup patches.
>=20
> To preserve history, all of this should be done via:
> 	git mv oldpath/file newpath/file
> 	git commit -m newpath/file=20
> with some extra cleanups to Kconfig/Makefile files
> so no worries.
>=20
>=20

Joe is right, and that is the method that I have been using.

--=-ShGNBBPrHtUN8iJlfMWz
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAABAgAGBQJN7Q8HAAoJECTsCADr/EWUgpgH/ja+5SHsYqHT09X1CuwAZHrq
0D150gf5XwHrtQuR0DeoRj1W1CZXcnIWM8ikk/gR4wcfFqSXOt0yv6KO8cN6r03N
IGjWyWgRnwJRbzRio6rjdxvbNe6bzsJOMNmP6KBQYrB4HlbGDRfLd2l9wsDyz96s
2LRRcXBqRq+Xsp3puiSZUWzoEcGddZjExpXA6xfr1svKXA9uxltZVopxE3oRwgp0
B+Er/L5lsh0pSMgQFvfbIgaJjv+SwkDyrs4PdJ8puF3rcVUOpI4pzO+sgMZZq0kb
dX+rd5euLUQ23jgJs50xL+lj2J2XNCDyr/ZRv7c3O9+QeAcjTyLMASqAClyyuLU=
=ZeH4
-----END PGP SIGNATURE-----

--=-ShGNBBPrHtUN8iJlfMWz--

