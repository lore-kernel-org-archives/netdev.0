From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [iproute2 PATCH] iplink: Support VF Trust
Date: Mon, 12 Oct 2015 11:59:30 -0700
Message-ID: <1444676370.2781.15.camel@intel.com>
References: <7F861DC0615E0C47A872E6F3C5FCDDBD05F42A95@BPXM14GP.gisp.nec.co.jp>
	 <20151012095423.4feabde1@urahara>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-Jj/061SlDJjrhD4cDeIf"
Cc: "Rose, Gregory V" <gregory.v.rose@intel.com>,
	Or Gerlitz <gerlitz.or@gmail.com>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	"Skidmore, Donald C" <donald.c.skidmore@intel.com>,
	"intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
	"nhorman@redhat.com" <nhorman@redhat.com>,
	"jogreene@redhat.com" <jogreene@redhat.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	"Choi, Sy Jong" <sy.jong.choi@intel.com>,
	Rony Efraim <ronye@mellanox.com>,
	Edward Cree <ecree@solarflare.com>,
	David Miller <davem@davemloft.net>,
	"sassmann@redhat.com" <sassmann@redhat.com>
To: Stephen Hemminger <stephen@networkplumber.org>,
	Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:53909 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751081AbbJLS7q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Oct 2015 14:59:46 -0400
In-Reply-To: <20151012095423.4feabde1@urahara>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-Jj/061SlDJjrhD4cDeIf
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2015-10-12 at 09:54 -0700, Stephen Hemminger wrote:
> On Wed, 7 Oct 2015 10:06:32 +0000
> Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com> wrote:
>=20
> > From: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>
> >=20
> > Add IFLA_VF_TRUST message to trust the VF.
> > PF can accept some privileged operation from the trusted VF.
> > For example, ixgbe PF doesn't allow to enable VF promiscuous mode
> until
> > the VF is trusted because it may hurt performance.
> >=20
> > To trust VF.
> >  # ip link set dev eth0 vf 1 trust on
> >=20
> > To untrust VF.
> >  # ip link set dev eth0 vf 1 trust off
> >=20
> > Signed-off-by: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>
>=20
> I am waiting until this is accepted into kernel before merging it
> into iproute2.

Yeah, I figured.  I had him resend it since our validation team did not
have these changes available to test Hiroshi's latest set of
driver/core changes.
--=-Jj/061SlDJjrhD4cDeIf
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAABCgAGBQJWHAMSAAoJEOVv75VaS+3OB5oP/RDVbak7xMhyO2+ojDaYg/ei
qiVq1fUs19IFY60akcGEjOfD4mcXqmmfBk9YIVMxmh8iOblqYennZin2zvr5Nyzq
fzHzR0lVhDqnPAigBVwjJ31qWTa7eyl6G2I0DQW2Fx6SnZBkBiouxLvqpugSAb5t
hT4xOm8IuG2Sg2El0WeJdXnPvPriR/xrtXgv6jRNC3AapJnD4wULkhF6ZH8DZb2L
IP4i9CAncnjeUdXDLBk3WkiLVYT0XOuiOfY60wR6e8j7xrw7lqg8Thf0Gm/9o4my
WRxTld5Jw/xDclT512GC0ezkzc0eB9M3dKjgEi7aXqznEhyyAU8MRAfvSia3ofQd
ARbjO/3u1IFVpTRoQNxfJZUsgXDqZ2laWO0PHhdcLQ2GSc1QEJdbtA0JFtyDFQ++
bhdibXC6ezB5RUrdV1mbbOYW/MHdjr7CBmyl6LbcBZ8k0oGwhZHYhzUndiHoOo+r
v64TYBY8abQPA8bpnf18Izuwa260LHd9H+9nk1Hi697bIjuOpIltCi4XI66Yp9SE
VLqOXEa87WMAwnMaHwJ1ndJ/kc0mo8ojBz6mqXMWxob6R/lIu0GdbQg7FNpyflaW
smUrpVavf1RnES8gVz6izgg9SpT1vJXHWzd4vNoe71pdk3op4KDA1BDoOI14L0Bt
dft9R7xUjOpU9uRRvuLr
=sV9X
-----END PGP SIGNATURE-----

--=-Jj/061SlDJjrhD4cDeIf--
