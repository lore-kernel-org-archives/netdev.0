From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH V3] net/dt: Add support for overriding phy configuration
 from device tree
Date: Tue, 04 Feb 2014 21:40:40 +0000
Message-ID: <1391550040.3003.28.camel@deadeye.wl.decadent.org.uk>
References: <7510122.cayuQ6qt8r@wuerfel>
	 <1389999459-9483-1-git-send-email-matthew.garrett@nebula.com>
	 <CAGVrzcZ4TFd=9KP+aoG47QbmqDJ1i23WBcEWDbzNRUfGmPvZHQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-Cl4GTycUti78AzhdcRFk"
Cc: Matthew Garrett <matthew.garrett@nebula.com>,
	netdev <netdev@vger.kernel.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Kishon Vijay Abraham I <kishon@ti.com>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAGVrzcZ4TFd=9KP+aoG47QbmqDJ1i23WBcEWDbzNRUfGmPvZHQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-Cl4GTycUti78AzhdcRFk
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2014-02-04 at 12:39 -0800, Florian Fainelli wrote:
> 2014-01-17 Matthew Garrett <matthew.garrett@nebula.com>:
> > Some hardware may be broken in interesting and board-specific ways, suc=
h
> > that various bits of functionality don't work. This patch provides a
> > mechanism for overriding mii registers during init based on the content=
s of
> > the device tree data, allowing board-specific fixups without having to
> > pollute generic code.
>=20
> It would be good to explain exactly how your hardware is broken
> exactly. I really do not think that such a fine-grained setting where
> you could disable, e.g: 100BaseT_Full, but allow 100BaseT_Half to
> remain usable makes that much sense. In general, Gigabit might be
> badly broken, but 100 and 10Mbits/sec should work fine. How about the
> MASTER-SLAVE bit, is overriding it really required?

Yes, it is entirely possible that one or other of the clock modes
(locally generated vs recovered) is not reliable.

> Is not a PHY fixup registered for a specific OUI the solution you are
> looking for?
[...]

The fault is in the board, not the PHY.

Ben.

--=20
Ben Hutchings
One of the nice things about standards is that there are so many of them.

--=-Cl4GTycUti78AzhdcRFk
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAUvFeWOe/yOyVhhEJAQpirA/+PmyKReUFK6DjC7cFUusU3xKKTESbGss9
fOMUi5Cb218mFx6bJi6AYqaK7W9EimD0SjzsV1E2NzAE+120/FcETG+nftYkhXjR
7/Zzyoxg2HFKAx/EhRznb1pmr0zS0b0ixQAI7Yc9MvV3pLUQwqrX2I8vcWHr0eyf
ggdTO7NRe2CQZf8WRXrY4WGfNge6bVm95LmqP2cyMknMLNL8sip3G0I0V8CW/ni8
57d+0UTI128jNsNFtVIGgivyz5N4u727lexAFIvxStUuH3JN907YkKDTPRIJK78S
5qf57AdJNUJfgIhpzgnKFTG1+lXXf8ZYlBzTSp1pqdcXKHf2w9D6kLg1om1ZSgdl
bOl0PWbtdqc7FU4cVrB0lAJluEy6ABSQSzZaMDlWT4NHR8gqRu5IaY68vib+AxyS
odynOkWwY6b+hTSV9r2JCapcCd/2mcNgQ9E5N5pepO4bSL8CNlH5/m/PQnvjlxiq
cWdaiHxu4wOxlAPnwScM2jgeFHOksLnCdFNQNFev9TUAgye7jYOiWgk5o/7E+lM1
hcGpA047u41ul6FLMMUuNnlbJV6aGnBNgjdEJiLqUbLYrA9MefcgJVWN90Wrcabk
ftBseLlr/Jc8RNHr9fwPqOTaKxPotq6acquvrrsFfWsjWsTM+BI1Hs8REUTApahW
blwiyDniAuQ=
=fXK0
-----END PGP SIGNATURE-----

--=-Cl4GTycUti78AzhdcRFk--
