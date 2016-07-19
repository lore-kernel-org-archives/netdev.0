From: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH V2] Add flow control to the portmapper
Date: Tue, 19 Jul 2016 20:32:53 +0300
Message-ID: <20160719173253.GL20674@leon.nu>
References: <1468869810-64420-1-git-send-email-shiraz.saleem@intel.com>
 <20160719054006.GF20674@leon.nu>
 <20160719145024.GA69464@ssaleem-MOBL4.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="OGLMwEELQbPC02lM"
Cc: dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org, e1000-rdma-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Mustafa Ismail <mustafa.ismail-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
To: Shiraz Saleem <shiraz.saleem-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20160719145024.GA69464-GOXS9JX10wfOxmVO0tvppfooFf0ArEBIu+b9c/7xato@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--OGLMwEELQbPC02lM
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Jul 19, 2016 at 09:50:24AM -0500, Shiraz Saleem wrote:
> On Tue, Jul 19, 2016 at 08:40:06AM +0300, Leon Romanovsky wrote:
> >=20
> > You are the one user of this new inline function.
> > Why don't you directly call to netlink_unicast() in your ibnl_unicast()
> > without messing with widely visible header file?
>=20
> Since there is a non-blocking version of nlmsg_unicast(), the idea is=20
> to make a blocking version available to others as well as maintain=20
> consistency of existing code.
>=20

In such way, please provide patch series which will convert all other
users to this new call.

=E2=9E=9C  linux-rdma git:(master) grep -rI netlink_unicast * | grep -I 0
kernel/audit.c: err =3D netlink_unicast(audit_sock, skb, audit_nlk_portid, =
0);
kernel/audit.c:         netlink_unicast(aunet->nlsk, skb, dest->portid, 0);
kernel/audit.c: netlink_unicast(aunet->nlsk , reply->skb, reply->portid, 0);
kernel/audit.c: return netlink_unicast(audit_sock, skb, audit_nlk_portid, 0=
);
samples/connector/cn_test.c:    netlink_unicast(nls, skb, 0, 0);

Thanks

--OGLMwEELQbPC02lM
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJXjmRFAAoJEORje4g2clinaQwQALZueTQ3825wIPHFPq+tnDWn
4lRBcf7uT+IHsm+G9n9s6HNFWfV4bzGz/rd2yX7h30CWgXHttgwtji3pN3esZcOj
VFR9joQ7Fq9nxrDl1V4lqNjv0kt1ZFCo85hpyy8nkAemn0/cAAo4eVYQFkRhoW1e
XWVropuZv/UtQ6QGMbK2i2+s94RASx0b6w7PdiLOQLg+VRrBG/+NSEMDd2lP/IeM
EcgT9AISZ7vjaOTkejDXy/BAfNcTqrigStAz2K8BUc4g8S3QBUyq0a4q/MlmL/Bv
PnWYpgLRFFbr/U+WhUlTg3qzkqYDB6Jfv+rWjO9xcC7YdyKhAyXV4CqbIKKmW9/6
ZYnm+Nt2dO/p/GgZ8y3PbRymj7YWdq+eTY+l7v83Us1uvR2RQhFnHhjjTEcYvBWI
eJiyK8Gnp3lrWjxeBhyZ6QiPnSmdwk7m3yr/TdZy5OX2cM23lx81vEn2kAV79LVD
/VoJI2lniN66BJzgRLNFJ+iUpVoL5L/RM+sY31a4ZO9gpE1lRhbS9EZRcE/vtEYs
sF7HxsqgIE4qRrC5HF9PgFEG7TCA+fJoP9+zR/JIebiMbbm6fjVZ7TACX4LQNheO
uXsX0BYzu4gP55+5lFc/Xgqf/zUez5ucNyh7CO987h3cKYZFvdtGLRh6Czvf4JJ0
o5QiGAOZbm+AXbcojJBO
=DKmi
-----END PGP SIGNATURE-----

--OGLMwEELQbPC02lM--
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
