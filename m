From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [RFC 1/5] net/ethtool: introduce a new ioctl for per queue
 setting
Date: Sat, 19 Dec 2015 03:37:39 +0000
Message-ID: <1450496259.30687.12.camel@decadent.org.uk>
References: <1450335081-3012-1-git-send-email-kan.liang@intel.com>
	 <1450495632.30687.3.camel@decadent.org.uk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-rpd4TnQgPg0/P7w9a6FC"
Cc: jesse.brandeburg@intel.com, andi@firstfloor.org,
	f.fainelli@gmail.com, alexander.duyck@gmail.com,
	jeffrey.t.kirsher@intel.com, shannon.nelson@intel.com,
	carolyn.wyborny@intel.com, donald.c.skidmore@intel.com,
	mitch.a.williams@intel.com, ogerlitz@mellanox.com,
	edumazet@google.com, jiri@mellanox.com, sfeldma@gmail.com,
	gospo@cumulusnetworks.com, sasha.levin@oracle.com,
	dsahern@gmail.com, tj@kernel.org, cascardo@redhat.com,
	corbet@lwn.net
To: kan.liang@intel.com, netdev@vger.kernel.org, davem@davemloft.net,
	bwh@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:53542 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752935AbbLSDhr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Dec 2015 22:37:47 -0500
In-Reply-To: <1450495632.30687.3.camel@decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-rpd4TnQgPg0/P7w9a6FC
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sat, 2015-12-19 at 03:27 +0000, Ben Hutchings wrote:
> On Thu, 2015-12-17 at 06:51 +0000, kan.liang@intel.com wrote:
> > From: Kan Liang <kan.liang@intel.com>
> >=20
> > Introduce a new ioctl ETHTOOL_PERQUEUE for per queue parameters setting=
.
> > The following patches will enable some SUB_COMMANDs for per queue
> > setting.
> >=20
> > Signed-off-by: Kan Liang <kan.liang@intel.com>
> > ---
> > =C2=A0include/uapi/linux/ethtool.h | 18 ++++++++++++++++++
> > =C2=A0net/core/ethtool.c=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0| 17 +++++++++++++++++
> > =C2=A02 files changed, 35 insertions(+)
> >=20
> > diff --git a/include/uapi/linux/ethtool.h b/include/uapi/linux/ethtool.=
h
> > index cd16291..05bc92a 100644
> > --- a/include/uapi/linux/ethtool.h
> > +++ b/include/uapi/linux/ethtool.h
> > @@ -1144,6 +1144,22 @@ enum ethtool_sfeatures_retval_bits {
> > =C2=A0#define ETHTOOL_F_WISH=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0(1 << ETHTOOL_F_WISH__BIT)
> > =C2=A0#define ETHTOOL_F_COMPAT=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0(1 << ETHTOOL_F_COMPAT__BIT)
> > =C2=A0
> > +#define MAX_QUEUE		4096
> > +#define MAX_QUEUE_MASK		(MAX_QUEUE / 64)
> > +
> > +/**
> > + * struct ethtool_per_queue_op - apply sub command to the queues in ma=
sk.
> > + * @cmd: ETHTOOL_PERQUEUE
> > + * @queue_mask: Mask the queues which sub command apply to
> > + * @sub_command: the sub command
> > + * @data: parameters of the command
[...]

You also need to make it clear that there's a complete command
structure following for each of the queues addressed, both for get and
set. =C2=A0I.e. set does not apply the same settings to all queues.

Ben.

--=20
Ben Hutchings
Always try to do things in chronological order;
it's less confusing that way.
--=-rpd4TnQgPg0/P7w9a6FC
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAVnTRA+e/yOyVhhEJAQqoBg/9EhZ05Al2RlmjXd1PzkO9FQS+CcCv0wtw
/00ocJ9itGA3PLwYOg6zC91cc0CZ5aCPlrhZEosf0kNNHfU49ct3YbkXLv+Ejg2v
6QjWxgQrxT1XvX2bOktXQdAKC1ogTkWR/VX1/fFZaafSdvoOQ6dVXBZULW/DZjV0
QPal9Sgb82V6nT+8NCmMWrh1yyM0atgut3nSbdR8Tk/+GhXLkJgK0JD7tKh78/5d
zf+HOkzD66TMVBwtI61t1EtLS+2oPzHipQUyLPH+fyIF464O0ygC0zwqw7XkEttB
mR+pjhY+vj1tuirhhDb/YB+0Ltv3mqeUet6UOHo3/T0uSQUIDRT4cHJDriRKu1yA
aAIqTOXrL802q+o5Vd5uxW6mnAlB370Wt/7cMZtM9yTQOvgHu0NeTfgAZI34Nunz
2cbO083aVVRxu6tmR5htHHH/cxD2hUv+sMrrxWGNBmP6Vdb/57YGuqFIIZ4uV8th
vNrdrkHbsyhrlai2Gv7SxxpXNgKbs16ADafrDXR5k1myZ6Ij2WTNjiXZTPxJT0Sl
PfXFmnZDVMBZjNkJIlnzbnu3oOdlHmJWMHBAf3Q2jGRjoq+XmtIPD5+hlstaC6gx
ycR9h14nv1hCkE1InITKC08evlT84gZ1a2exAXI2JULomfx7WcFD3n4OTs84/yGo
v1lOIuk6EEA=
=uhBw
-----END PGP SIGNATURE-----

--=-rpd4TnQgPg0/P7w9a6FC--
