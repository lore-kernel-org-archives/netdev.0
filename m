From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: Fw: [Bug 79891] New: Router causes TCP retransmits for windows
 hosts after "ip_forward: fix inverted local_df test"
Date: Fri, 11 Jul 2014 19:11:50 +0100
Message-ID: <1405102310.26540.83.camel@deadeye.wl.decadent.org.uk>
References: <20140710064433.1fd17105@samsung-9>
	 <CAHA+R7N0ZgLfZNMrnHyRD+C=rGD86QXVkE0weLOLCM9npXMozg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-DMYllYvn2Tr9qqGt8pKi"
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	stable <stable@vger.kernel.org>
To: Cong Wang <cwang@twopensource.com>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <CAHA+R7N0ZgLfZNMrnHyRD+C=rGD86QXVkE0weLOLCM9npXMozg@mail.gmail.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-DMYllYvn2Tr9qqGt8pKi
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2014-07-10 at 10:11 -0700, Cong Wang wrote:
> On Thu, Jul 10, 2014 at 6:44 AM, Stephen Hemminger
> <stephen@networkplumber.org> wrote:
> >
> > After upgrading a router to Linux 3.2.60 most windows machines behind i=
t
> > started experiencing connection stalls. Downgrade to 3.2.59 resolved th=
e
> > problem. Using git bisect I pinpointed it to
> > "59d9f389df3cdf72833d5ee17c3fe959b6bdc792 is the first bad commit", whi=
ch
> > entered the kernel from here
> > http://marc.info/?l=3Dlinux-netdev&m=3D139949081418806&w=3D2
> >
>=20
> This commit should have been reverted for older kernels like 3.2.y.

Really?  We already had fe6cc55f3a9 ("net: ip, ipv6: handle gso skbs in
forwarding path") backported in 3.2.57.

Ben.

--=20
Ben Hutchings
To err is human; to really foul things up requires a computer.

--=-DMYllYvn2Tr9qqGt8pKi
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIVAwUAU8Ao6+e/yOyVhhEJAQoptA//c6J04aFx0zGSZcQhmUgD5W4m02dp4/dF
sKUjMcZMCW4W5+oRI1oIvXlkfKXHMFRkDl+mZ7Oqe+JqbAPMeBqgHWKzVlHSigfs
5zIxmubkcA/UXVpJYPxAbicTAX/xjWQEKM61nFi87spnLoVyiQ9AAewgB+VxPk7d
D7I6zvpHS7HwheJ7tP2Rh72gbSZTaO2QZWPoMZNs39n9QzwRKfaYXth2AP3SYb2y
l7rJ8af8xWbmQGivlIKY/49enD1CXZi0sft/NTninxNxFjffTXFwI1qo0pfE3rpk
eIvlryOMgQXY63r33zkDxZKav7p9JCziT1GodqZTAgrVh6B9rkXYwZ425sIPyBZq
V4wo+F6NeZCxPzuXJ2L0EV30yrHHXwcqDhHphZv8gHlvvn5VJYtEkkJdQtzL7CI+
vqGEmo2Oms8qKKTDTFLZBr4XLSbOI1GNUGXfisw+COhxI9+ziCEaojf/Lop+2dyw
vpKIYQaZghzsE9fyxEtnIPo0dxZ95vSsPkIbrgmmwamEn/08JqjCFwMLKk89Y6YP
M2TNhYicmUp05Gnps76wly4Qw6PhMNGvFJdO31S482rmg2CT8ZEKgGh3oA7tasQ+
D8vSFtSh7ICh7ZZQyjoaexSfDWd2BZumJOfXWr2hO0KhQl8kzo/qHfbZu9M3JWao
DpHO0uGpbLc=
=mq8Z
-----END PGP SIGNATURE-----

--=-DMYllYvn2Tr9qqGt8pKi--
