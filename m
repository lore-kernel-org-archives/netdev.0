From: Sebastian Reichel <sre@kernel.org>
Subject: Re: [PATCH 0/4] TI Bluetooth serdev support
Date: Sun, 30 Apr 2017 18:04:30 +0200
Message-ID: <20170430160430.rmyuo6sdrkrjxjg6@earth>
References: <20170405183005.20570-1-robh@kernel.org>
 <CAHCN7xJUxZm1qKAxT0kaK6qoDg+HWOJK7sTH-q9za4HJuUwe8Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============3355830355590808606=="
Cc: Mark Rutland <mark.rutland@arm.com>, Rob Herring <robh@kernel.org>,
 Johan Hedberg <johan.hedberg@gmail.com>, devicetree@vger.kernel.org,
 Gustavo Padovan <gustavo@padovan.org>, Marcel Holtmann <marcel@holtmann.org>,
 Wei Xu <xuwei5@hisilicon.com>, linux-bluetooth@vger.kernel.org,
 Eyal Reizer <eyalr@ti.com>, netdev@vger.kernel.org,
 Satish Patel <satish.patel@linaro.org>, linux-arm-kernel@lists.infradead.org
To: Adam Ford <aford173@gmail.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <CAHCN7xJUxZm1qKAxT0kaK6qoDg+HWOJK7sTH-q9za4HJuUwe8Q@mail.gmail.com>
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


--===============3355830355590808606==
Content-Type: multipart/signed; micalg=pgp-sha512;
	protocol="application/pgp-signature"; boundary="ittejsuw3bnkg4rp"
Content-Disposition: inline


--ittejsuw3bnkg4rp
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi,

On Sun, Apr 30, 2017 at 10:14:20AM -0500, Adam Ford wrote:
> On Wed, Apr 5, 2017 at 1:30 PM, Rob Herring <robh@kernel.org> wrote:
> > This series adds serdev support to the HCI LL protocol used on TI BT
> > modules and enables support on HiKey board with with the WL1835 module.
> > With this the custom TI UIM daemon and btattach are no longer needed.
>=20
> Without UIM daemon, what instruction do you use to load the BT firmware?
>=20
> I was thinking 'hciattach' but I was having trouble.  I was hoping you
> might have some insight.
>=20
>  hciattach -t 30 -s 115200 /dev/ttymxc1 texas 3000000 flow  Just
> returns a timeout.
>=20
> I modified my i.MX6 device tree per the binding documentation and
> setup the regulators and enable GPIO pins.

If you configured everything correctly no userspace interaction is
required. The driver should request the firmware automatically once
you power up the bluetooth device.

Apart from DT changes make sure, that the following options are
enabled and check dmesg for any hints.

CONFIG_SERIAL_DEV_BUS
CONFIG_SERIAL_DEV_CTRL_TTYPORT
CONFIG_BT_HCIUART
CONFIG_BT_HCIUART_LL

-- Sebastian

--ittejsuw3bnkg4rp
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAABCgAdFiEE72YNB0Y/i3JqeVQT2O7X88g7+poFAlkGCwwACgkQ2O7X88g7
+prHRA/+J6rOroKLlBvWLgILb8/Biu8/OLi/9hB6q4yOOiSv934FwERd9OyZ8eCd
pQiZQL9GRCN+DE+PvfE3iVh7m6DBQZ8Mq/GyI1tlDwt/oYdTgGw8qhelK33Kxdyd
nm/SJwlahlj4FybH0wrnXwj7lyDnuPbtR55RRiw/5cOwmoeGMyFqWh09mcoOQedU
xYM6wzVQvIdQTUanMRh4hHic6gtylwHPVNeg6wDDXCbQf2PBVrt5cxzQymVzZFaP
fsm9aTSzPzf0R7OvkmKr0klI1xjrLNsUU3Sp1VkmOi9XDN/cl+GXHd8WL/QGoxCD
K9jMaYTPjClzKYFsZa02GZ+Wur1L0T0uwC5icISnatzheyEXWixc0wiyZxsXXQqd
kJLY5JVoyWh6q9i9rUsPqOTuEexDhTBnZslJWvslP0TZ2vIxCzN/hZCrwOmC28NI
Ph++2SZO8cBUrgEhADhuEi6Gx68R0hDDQvfxi482pjnULAFFr8lU9m+mKlXTDWdg
SypyhFEKR3GvS7TzDhgw1qb6dho9z37nFUnRApfxR7BfLcJxv+KSUIhU+teWRAgk
1qdvofxh1jH0sNOG8upizrh41z4gx6DBcgCZb7I+RB/x/nEB8pgIeerEu5c8K8G4
swoetuqD5vcs6ZpNHvKGlfR4qKF7UAX3Fyk8a6Xw1Ohhk3O4wlU=
=Nh8c
-----END PGP SIGNATURE-----

--ittejsuw3bnkg4rp--


--===============3355830355590808606==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
linux-arm-kernel mailing list
linux-arm-kernel@lists.infradead.org
http://lists.infradead.org/mailman/listinfo/linux-arm-kernel

--===============3355830355590808606==--
