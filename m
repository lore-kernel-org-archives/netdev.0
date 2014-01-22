From: Mark Brown <broonie@kernel.org>
Subject: Re: [PATCH RFC 4/6] net: rfkill: gpio: add device tree support
Date: Wed, 22 Jan 2014 12:38:19 +0000
Message-ID: <20140122123819.GH17314@sirena.org.uk>
References: <1389941251-32692-1-git-send-email-wens@csie.org>
 <201401211335.16885.arnd@arndb.de>
 <CAAVeFuKFfAvSPYLmvWV5jjT-peZFJ8sJ2bbh4F=JAYoWLhjZpA@mail.gmail.com>
 <201401211950.07011.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============2644417091909250083=="
Cc: Alexandre Courbot <gnurou@gmail.com>,
 Heikki Krogerus <heikki.krogerus@linux.intel.com>,
 "devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
 netdev <netdev@vger.kernel.org>, Linus Walleij <linus.walleij@linaro.org>,
 linux-wireless <linux-wireless@vger.kernel.org>,
 linux-kernel <linux-kernel@vger.kernel.org>,
 "David S. Miller" <davem@davemloft.net>,
 "linux-gpio@vger.kernel.org" <linux-gpio@vger.kernel.org>,
 linux-sunxi <linux-sunxi@googlegroups.com>,
 Maxime Ripard <maxime.ripard@free-electrons.com>, Chen-Yu Tsai <wens@csie.org>,
 Mika Westerberg <mika.westerberg@linux.intel.com>,
 Johannes Berg <johannes@sipsolutions.net>,
 "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <201401211950.07011.arnd@arndb.de>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org


--===============2644417091909250083==
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="qGF5p/tMraZs2sto"
Content-Disposition: inline


--qGF5p/tMraZs2sto
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Jan 21, 2014 at 07:50:06PM +0100, Arnd Bergmann wrote:

> I should have another look at the debugfs representation, but isn't
> there a global namespace that gets used for all gpios?  Neither the
> con_id nor the name that the driver picks would be globally unique
> and stable across kernel versions, so they don't make a good user
> interface.

Currently the globally unique name is the GPIO number but that's not
stable since it gets dynamically assigned. =20

> I think what we want here is a system-wide unique identifier for
> each gpio line that may get represented in debugfs, and use a new
> DT mechanism to communicate that.

We've mostly been using things based off dev_name() for stability.

--qGF5p/tMraZs2sto
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAEBAgAGBQJS37u4AAoJELSic+t+oim9G+MQAJErIQGqQz6x1HTjAObSjhOE
CuL1qSxTNyzHD4QvUc9PJ15IEvqe2TK+1AUgYDEGIkZ2kwwGBZAhYPpA0eIzecrO
9u0ZMNvoq+Nw85NjA6/CZCBTJ+fo3vX9E2STkddxez6SE4O21cyRxLJ03QKIuR/5
CsAP2Y7Z4el7aaSeQc/6Aoc1/0Hc93rMYOCNyCou7tWX5HjC+uA+zXaYLh8XetM+
2AlnhqMTl03q6F32t7YxeGcnMxWkV2CaPVEuh1F8oMsSCXTzwOFtOE49N395C8ES
5swiFcL1Z/X6BrfJ7GvMPOrkGFSeEetVzUSUoaHSW1KXtsZfGXxEM2eIX2YnYkbw
olt+eAuQ0HsjKg6iC9SzKa6ykZtdza8owmXVJAyjW+i5l3y+3KNWIO0K1X64lMZA
SJdyoJ77nNtZET6UWF65WvRx8oXK80vdrltWDJ8sHfc0FZ7cPCTeZrZ4QjXcpBMp
lmXCXgKdXhmSQin24V+bdZFj1bwYEOjhrtqgIqVsqJLIHNpqyob+7ik2vv1h4Dzw
U/yQnVdpbns7WELoAzlslQW3t+FVwbeRyhrIRc8cZY4LTKTjfQHfN5bq4z/qgCuN
kA/9NUZpmgpsxAJnEo0iv0b9zE7JEbX/Z38I40E7VurzH65sn9w/kCtGf7G0ffCY
44oDEnRbgyAscMd4tDlQ
=Hgls
-----END PGP SIGNATURE-----

--qGF5p/tMraZs2sto--


--===============2644417091909250083==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
linux-arm-kernel mailing list
linux-arm-kernel@lists.infradead.org
http://lists.infradead.org/mailman/listinfo/linux-arm-kernel

--===============2644417091909250083==--
