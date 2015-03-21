From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH net-next v2 1/3] switchdev: add swdev ops
Date: Sat, 21 Mar 2015 00:04:13 +0000
Message-ID: <1426896253.32382.32.camel@decadent.org.uk>
References: <1426470321-48669-1-git-send-email-sfeldma@gmail.com>
	 <1426470321-48669-2-git-send-email-sfeldma@gmail.com>
	 <1426892453.32382.12.camel@decadent.org.uk>
	 <CAE4R7bA8xndMw4Pdpj1S-CEf3z4hF56Bu1eU8PrEccCZn+BMpQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-CXFyjNI93B0bW5ouksEA"
Cc: Netdev <netdev@vger.kernel.org>,
	=?UTF-8?Q?Ji=C5=99=C3=AD_P=C3=ADrko?= <jiri@resnulli.us>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	"simon.horman@netronome.com" <simon.horman@netronome.com>
To: Scott Feldman <sfeldma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:50229 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750994AbbCUAEV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Mar 2015 20:04:21 -0400
In-Reply-To: <CAE4R7bA8xndMw4Pdpj1S-CEf3z4hF56Bu1eU8PrEccCZn+BMpQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-CXFyjNI93B0bW5ouksEA
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2015-03-20 at 16:58 -0700, Scott Feldman wrote:
> On Fri, Mar 20, 2015 at 4:00 PM, Ben Hutchings <ben@decadent.org.uk> wrot=
e:
> > On Sun, 2015-03-15 at 18:45 -0700, sfeldma@gmail.com wrote:
> > [...]
> >> +/**
> >> + * struct switchdev_ops - switchdev operations
> >> + *
> >> + * int (*swdev_parent_id_get)(struct net_device *dev,
> >> + *                         struct netdev_phys_item_id *psid);
> >> + *   Called to get an ID of the switch chip this port is part of.
> >> + *   If driver implements this, it indicates that it represents a por=
t
> >> + *   of a switch chip.
> >> + *
> >> + * int (*swdev_port_stp_update)(struct net_device *dev, u8 state);
> >> + *   Called to notify switch device port of bridge port STP
> >> + *   state change.
> >> + *
> >> + * int (*swdev_fib_ipv4_add)(struct net_device *dev, __be32 dst,
> >> + *                        int dst_len, struct fib_info *fi,
> >> + *                        u8 tos, u8 type, u32 nlflags, u32 tb_id);
> >> + *   Called to add/modify IPv4 route to switch device.
> >> + *
> >> + * int (*swdev_fib_ipv4_del)(struct net_device *dev, __be32 dst,
> >> + *                        int dst_len, struct fib_info *fi,
> >> + *                        u8 tos, u8 type, u32 tb_id);
> >> + *   Called to delete IPv4 route from switch device.
> > [...]
> >
> > This isn't correct kernel-doc syntax.
>=20
> It was a cut-and-paste from netdevice.h.  Give me an example of
> correct syntax, and I'll fix these.

/**
 * struct switchdev_ops - switchdev operations
 * @swdev_parent_id_get: Called to get an ID of the switch chip this
 *	port is part of.  If driver implements this, it indicates that
 *	it represents a port of a switch chip.
 * ...
 */

Ben.

--=20
Ben Hutchings
If you seem to know what you are doing, you'll be given more to do.

--=-CXFyjNI93B0bW5ouksEA
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIVAwUAVQy1fue/yOyVhhEJAQq6lg//QXKo3bJ9SdpxdKWVsO8TWzBYBqnAXfNB
W6RPuNyqIBXejLGketrLIUJ0syhg2C829SydjXPyry7p4BnvMmSy5unJ8zoBe/n0
Ber/+DXKL2X1DV2VHpK0C0FbnmrQRXxLu8MSScBv7TRaqXM0mMXzGlMINd3AgdBc
Tc3YOyvBLX96vqhRHfjGGs89Ppz0uU93KytUkm+HQohopLJkMI7EdscQvLjneY6M
hDPjfVIQSTw62wv/t2TkktT6DvltzfzEIqa8WBFyLRmmEKOI9Mg7gXQqva5msaP0
+td74zJ7A0Ivqk+u8CJ7dDI3YLLY7BzSjXYdJ9Ie6z1LIgRr4AqV2OonxAhNzHcC
XXy7mPbSw6SEhCYZsMrN3KfBHEUsCfJB3TdysEq2XhoPboD5tKuIM2ATuaMWBGB4
D47CbcQzfDt2Tk53eijBNOKdhJqCdYhsQaobEqAMfJdxBWbzyVqirvOddjWGeSQY
W733TcDHfIR+X/LK7LVCEZ+832kUJZkhJXvjk0jqNSyX0A105b9LozD/6FU8Gf9Z
Y9I22sj/Qd6rf/YgevBCvinZ28QdkEW6YKfhK1xPOPeEooVUGOroJ7Yy70kMXrhm
OeUEaXt4D76BEA/o2ymbd7F8/z/Lpj+b7XI0zJ6D382gnwiJ6AAYOX6B+uaEqRQ8
jarhHnjdmi8=
=NpCU
-----END PGP SIGNATURE-----

--=-CXFyjNI93B0bW5ouksEA--
