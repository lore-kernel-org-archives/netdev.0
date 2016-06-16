From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH net-next] net: ena: Add a driver for Amazon Elastic
 Network Adapters (ENA)
Date: Thu, 16 Jun 2016 19:06:52 +0100
Message-ID: <1466100412.27155.66.camel@decadent.org.uk>
References: <1465807573-11293-1-git-send-email-netanel@annapurnalabs.com>
	 <20160616175539.lt7iqjrlixagwfbh@f1.synalogic.ca>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-UG8Mrz7tRpzxgB0ow/gZ"
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	linux-kernel@vger.kernel.org, zorik@annapurnalabs.com,
	saeed@annapurnalabs.com, alex@annapurnalabs.com, msw@amazon.com,
	aliguori@amazon.com, antoine.tenart@free-electrons.com
To: Benjamin Poirier <benjamin.poirier@gmail.com>,
	Netanel Belgazal <netanel@annapurnalabs.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160616175539.lt7iqjrlixagwfbh@f1.synalogic.ca>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-UG8Mrz7tRpzxgB0ow/gZ
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2016-06-16 at 10:55 -0700, Benjamin Poirier wrote:
> On 2016/06/13 11:46, Netanel Belgazal wrote:
[...]
> > +static ssize_t ena_show_small_copy_len(struct device *dev,
> > +				=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0struct device_attribute =
*attr, char *buf)
> > +{
> > +	struct ena_adapter *adapter =3D dev_get_drvdata(dev);
> > +
> > +	return sprintf(buf, "%d\n", adapter->small_copy_len);
> > +}
> > +
> > +static DEVICE_ATTR(small_copy_len, S_IRUGO | S_IWUSR, ena_show_small_c=
opy_len,
> > +		=C2=A0=C2=A0=C2=A0ena_store_small_copy_len);
>=20
> This is what many other drivers call (rx_)copybreak. Perhaps it's time
> to add it to ethtool as well?
[...]

There is the 'tunable' ethtool API for random parameters like
rx_copybreak. =C2=A0The ethtool utility doesn't support it yet, though.

Ben.

--=20
Ben Hutchings
Life is what happens to you while you're busy making other plans.
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0- John
Lennon

--=-UG8Mrz7tRpzxgB0ow/gZ
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJXYuq8AAoJEOe/yOyVhhEJLjQQANNvKlQeWG/cr1zTforuskPq
rSmyZzZt+vNU5GlJowqbx0OkWGyLZ9+O/hQ8ipynAgiLwa5mSCKn7XAccfmK6Pg8
jd1s2XycgTCpcHj3JsTkfnIew4go/dHIrCLEjYgJw8q4/RmbgxAydqV52K0daHpc
jW7rfUSXzjJN7CmG7ntkzv72byvqyiym4M6hnc/AMhHxgYfPt41i+F155qvZvNsj
doYE110ygcJHCozvmb2cYIoUoxDAyzwWeYGrZRuwXQdywbB7GPfK339aFx3F8jiO
tLONsRAP3NegAtjMnhY3/suwzdhqRpfY4ZRglOkEesB/N+bsQEahj09yKD2tbv4B
12xQhpiort0hjZEgEWWshKFkjgnat08wbIT3Dn1NK2D1o16O1YHsG2BEoUcBWBQP
xm984ubrYdjLrk6G1qON98e28BuE+e1RPr0Pl6yu9CoQvqRVOyxWaJ9e7ExCSEPs
ThhgYcrwG/0JmfOsZQzP+sLr/kCZseTVFz024hDIUm8u7fv2bbycX1oxsZ+V27j3
EYq2PNIOGVRqVabXPWfAGGgtxAXX+U85idPHqtyk4wjOzccCJZ0y14Z6VgAPBzsa
Olf02Bkgwx3pkkjvQi1rSVWVDtZpbIarjslhrUemrepKfYwViRDwyjy87ojlr/5Q
Nrp1A1Q56PTSIypLHNAF
=9d/i
-----END PGP SIGNATURE-----

--=-UG8Mrz7tRpzxgB0ow/gZ--
