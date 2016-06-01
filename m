From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH 5/5] ethernet: Use pci_(request|release)_mem_regions
Date: Wed, 01 Jun 2016 07:56:45 -0700
Message-ID: <1464793005.2960.3.camel@intel.com>
References: <cover.1464694724.git.jthumshirn@suse.de>
	 <3f24b687c31dea31a03cd3a529de790e942dd5bb.1464694724.git.jthumshirn@suse.de>
	 <20160601075956.GD11923@infradead.org>
	 <20160601085112.ve6k7bzspapjsswf@c203.arch.suse.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-NZJAPV9V/Hi0vA+scgWM"
Cc: Bjorn Helgaas <bhelgaas@google.com>, linux-pci@vger.kernel.org,
	linux-kernel@vger.kernel.org, Jay Cliburn <jcliburn@gmail.com>,
	Chris Snook <chris.snook@gmail.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	intel-wired-lan@lists.osuosl.org
To: Johannes Thumshirn <jthumshirn@suse.de>,
	Christoph Hellwig <hch@infradead.org>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <20160601085112.ve6k7bzspapjsswf@c203.arch.suse.de>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-NZJAPV9V/Hi0vA+scgWM
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2016-06-01 at 10:51 +0200, Johannes Thumshirn wrote:
> On Wed, Jun 01, 2016 at 12:59:56AM -0700, Christoph Hellwig wrote:
> > On Tue, May 31, 2016 at 02:05:13PM +0200, Johannes Thumshirn wrote:
> > > Now that we do have pci_request_mem_regions() and
> pci_release_mem_regions() at
> > > hand, use it in the ethernet drivers.
> >=C2=A0
> > This should probably be one patch per driver.
>=20
> I though if I do one patch per subsystem it'll be less a hassle for the
> individual maintainers, but if the netdev people want it as split up,
> I'll be
> doing it of cause.

Since almost all the changes are to Intel wired LAN drivers, if you just
split off the atheros change into a separate patch, I would be happy. =C2=
=A0Then
you could keep just one patch to change all the Intel drivers.
--=-NZJAPV9V/Hi0vA+scgWM
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJXTveuAAoJEOVv75VaS+3Ow7sQAIB9BzAWQr2V0t9BgRQz9GHS
lOn0GIIgn1ToZgxR4jx7CGap0ZGpLpPw1MV/75lQjyCgzyXr+ba6ureDu5C9RWTn
jQnAT37PY1Udua//spi/nOUgA1/nGzAnI+nMBu3QvfIUvfNI9p4cviXSf+QKoZ79
MkQpOT5WyQRZrsFDkgu2HAozVFD8aHRkFXeL5x7GCLb9VNY54+poYuWuvEkX/XAX
Dyua2lNUteUYVm6cS4pFVvUq+ebc+W1t2CsXCFGK7nLMrH6LnQkb8vbew47R3awA
bPKNmp6KDGZYyBZSfimmGnh2XF1UUqL4QBXvQ0UtJhq4Re9lLjFLhaII9X7ZZbIk
/9QgwkHlsWIP/eY2H8dmWLuRVX2XvECu6w4YoUR7ZjqNskIptllI26MybY9BNhqF
aZJiBDlOzm+BTauij5yIBMaiPn2vEhlL37eop3XN0W5YtYjzDVevRMcErzK7qYGg
9kFG6UfMHgzfVa/I0CjCe35K1kJsnVtOZPVu9o+GZwZZ2VdhLmsRr5W5wkcIxjsY
2znPkO0zDQC/JebOJ6lbVWr1BcH9FAjl6fTTz/Y7RoJY5wkHwUH5ip1fqsCw9xG0
GfMLgSmlSdVy2d6nK15pYBlnTLR7pjVDI72IkxyaVv4JdOWPZ0grQCrI2axOKpji
axgsQbF3m34yjSSApdSW
=LJ3C
-----END PGP SIGNATURE-----

--=-NZJAPV9V/Hi0vA+scgWM--
