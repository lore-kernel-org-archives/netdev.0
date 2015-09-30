From: Felipe Balbi <balbi@ti.com>
Subject: Re: [PATCH 02/23] usb-gadget: use per-attribute show and store
 methods
Date: Wed, 30 Sep 2015 11:43:01 -0500
Message-ID: <20150930164301.GP32625@saruman.tx.rr.com>
References: <1443189000-13398-1-git-send-email-hch@lst.de>
 <1443189000-13398-3-git-send-email-hch@lst.de>
 <20150927155053.GD16364@saruman.tx.rr.com>
 <20150928133514.GB30453@lst.de>
 <20150930161925.GJ32625@saruman.tx.rr.com>
 <20150930162046.GB2627@mtj.duckdns.org>
 <20150930163219.GN32625@saruman.tx.rr.com>
 <20150930163538.GC2627@mtj.duckdns.org>
Reply-To: <balbi@ti.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="zxEKvxCKojqA/Afl"
Cc: Felipe Balbi <balbi@ti.com>, Christoph Hellwig <hch@lst.de>,
	Joel Becker <jlbec@evilplan.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Pratyush Anand <pratyush.anand@gmail.com>,
	<target-devel@vger.kernel.org>, <cluster-devel@redhat.com>,
	<ocfs2-devel@oss.oracle.com>, <linux-usb@vger.kernel.org>,
	<netdev@vger.kernel.org>
To: Tejun Heo <tj@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from devils.ext.ti.com ([198.47.26.153]:47672 "EHLO
	devils.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752798AbbI3Qng (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Sep 2015 12:43:36 -0400
Content-Disposition: inline
In-Reply-To: <20150930163538.GC2627@mtj.duckdns.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--zxEKvxCKojqA/Afl
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Sep 30, 2015 at 12:35:38PM -0400, Tejun Heo wrote:
> On Wed, Sep 30, 2015 at 11:32:19AM -0500, Felipe Balbi wrote:
> > On Wed, Sep 30, 2015 at 12:20:46PM -0400, Tejun Heo wrote:
> > > On Wed, Sep 30, 2015 at 11:19:25AM -0500, Felipe Balbi wrote:
> > > > On Mon, Sep 28, 2015 at 03:35:14PM +0200, Christoph Hellwig wrote:
> > > > > On Sun, Sep 27, 2015 at 10:50:53AM -0500, Felipe Balbi wrote:
> > > > > > this (and the other helper below) could be macros just fine.
> > > > >=20
> > > > > They could, but they shouldn't.  Inlines are always preferable ov=
er
> > > > > function-like macros.
> > > >=20
> > > > says who ? And why ?
> > >=20
> > > Documentation/CodingStyle
> >=20
> > container_of() is type-safe, what is an inline function bringing as ben=
efit ?
>=20
> It's a general preference.  Because there's enough benefit to going
> with inline functions and there's extra benefit to be gained from
> having consistent style of code and documentation, as a general rule,
> we prefer inline functions over macros.  If you have specific
> technical arguments why macro is better, sure; otherwise, follow the
> conventions for consistency if for nothing else.

$ git grep -e "define.*container_of"  | wc -l
1003

Seems like there are *ton* of uses of container_of() wrapped within a simple
macro. What convention are you talking about, again ?

And again, what benefit is an inline function bringing in this specific
case ? As for a technical reason, we know the macro definition will be
copied Verbatim into the caller body. GCC might decide to not inline
those helpers (unlikely, but could).

--=20
balbi

--zxEKvxCKojqA/Afl
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJWDBEVAAoJEIaOsuA1yqREe2cQAIpb8h9T1Pv0hW4UiJ25KVke
GWgDbEgUOExFyEynAuQQ9S3EbNsK+6SJDKAl7sVmfiLn17NjDtfmUpWlRi+yjAcT
W4py0CDmZ2scyRhuAe/tLzGArbvl6b0tbzZxiXrXd30zOBAABQVduzu/zhTX5dfv
c273t+ZKlHXyV6z/ktmE2pdpfwx/CZrPejmYlE9zUPqhuAKRHyLB4kaENZBEVev9
iodkO1lbfcDHFwmWXeXVfXJwbEoMcz9yWZMo07wd6HNJ2J6FlVU+3JNVDtl+tXB4
T1lT1U2AnNPXSwSnyqOWkRnOPHPWWQlUP1LdxB57v9CQ0jyerCc1S04MqV3zpz7A
ux2Qlp/BWAul9V8Xr2qxEp/MkH1NV79uTRuGsS7YfeP+A7q6hfsMvD2W6Q0kjZj7
adyFS8i7/UzwEgIgnv4V7Zc0guXb/QWhCuztI9VCtILxGO9xzmAJUL1T6VDIV4pP
H1U6L5xgLA5fxEqiMXatkTtQgL9Rm3F0KFuxKk8mYZpwF0HFrqcJjY77ndG2EmhM
Vnlc1ArYZ3cj97DG8315TvQHLo/XFK6/8TOmZXX2Nq1FBgW8TIrktVFuyGaGIfAd
1kjHSCXTHAQtG70eOZaeoPsH5JKx+n83rAl/9B9uhaGxXLlQScZmMFUjZOzb4d/A
G/ZhAeZtSxs2XA7Lg+cI
=AELR
-----END PGP SIGNATURE-----

--zxEKvxCKojqA/Afl--
