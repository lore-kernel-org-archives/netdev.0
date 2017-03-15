From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next 01/13] i40evf: fix client warnings
Date: Tue, 14 Mar 2017 17:44:44 -0700
Message-ID: <1489538684.3541.22.camel@intel.com>
References: <20170314223308.53451-1-jeffrey.t.kirsher@intel.com>
         <20170314223308.53451-2-jeffrey.t.kirsher@intel.com>
         <20170314.173949.1164218813681950110.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha256";
        protocol="application/pgp-signature"; boundary="=-Oye7FizEujPvjoRoaaym"
Cc: faisal.latif@intel.com, netdev@vger.kernel.org, nhorman@redhat.com,
        sassmann@redhat.com, jogreene@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga07.intel.com ([134.134.136.100]:26976 "EHLO mga07.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750849AbdCOAox (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 14 Mar 2017 20:44:53 -0400
In-Reply-To: <20170314.173949.1164218813681950110.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-Oye7FizEujPvjoRoaaym
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2017-03-14 at 17:39 -0700, David Miller wrote:
> From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Date: Tue, 14 Mar 2017 15:32:56 -0700
>=20
> > From: Faisal Latif <faisal.latif@intel.com>
> >=20
> > The function prototype in i40evf_client.h are giving warnings while
> > compiling i40iwvf module. Move these function prototypes to
> > i40evf.h.
> > Also fix return code from u32 to int and this return code is
> > consistent with i40e_client.h
> >=20
> > Change-Id: Ie3757f844993aabc27654aaf02ec14fb985ad2c4
> > Signed-off-by: Faisal Latif <faisal.latif@intel.com>
> > Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
> > Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>=20
> There is no such i40evf_client.h header file in the tree.

Not sure how this got out of order, Mitch adds this file in patch #4

>=20
> > =C2=A0 int i40evf_config_rss(struct i40evf_adapter *adapter);
> > +int i40evf_lan_add_device(struct i40evf_adapter *adapter);
> > +int i40evf_lan_del_device(struct i40evf_adapter *adapter);
> > +void i40evf_client_subtask(struct i40evf_adapter *adapter);
> > +void i40evf_notify_client_message(struct i40e_vsi *vsi, u8 *msg,
> > u16 len);
> > +void i40evf_notify_client_l2_params(struct i40e_vsi *vsi);
> > +void i40evf_notify_client_open(struct i40e_vsi *vsi);
> > +void i40evf_notify_client_close(struct i40e_vsi *vsi);
> > =C2=A0 #endif /* _I40EVF_H_ */
>=20
> And these functions do not exist in the tree either.
>=20
> This really isn't acceptable.


--=-Oye7FizEujPvjoRoaaym
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----

iQIzBAABCAAdFiEEiTyZWz+nnTrOJ1LZ5W/vlVpL7c4FAljIjnwACgkQ5W/vlVpL
7c75yQ/8DR/Wvt+zYbYzNG1wY7PuP5e075dncD9zLxWdiLagyCllxvL6qaugKkOh
yV2halFIzwMTRkZ29+D78I8oc1weoTr4l2icRSDRDPqIZyhucwFyW129Q733iye7
Vurf21RaEJTbozpXSC1jEDXIh/4EqHy99Dc6mkE93Op44bw4Zvl0fKF+tTgXig1/
Q6KWWgOEC+/qJQvjhdrh1ZjjClztm8dSrcMKlG1zExgaj56TXeGiSWEGBUhWKfoY
fKrU+nPoMunist+I9C4r86ypzbhktDxkME5xbP415ds4n6FSo/WotwrX7n1Vg1tr
YChL0c/bRhPPz8hO4XKgDI19efdHCdmmGrWNp3W1Qu9QAqdj3fr9l7UbXCIdlK2r
uxlJKX0lBP9p5zvQNPI88gFdmiihk1LeJVxV47YAkGX08A9J9/PwtmnaboxqXngK
JOJVyxkmlVZqQyYDZHHF5AUjGd8aMDwTv7XGW17NOB5cO2QXYOm4jnGwTAYL3qLY
FVE7Np5F+zEgZRCynqmaKgGbcekmXgHthjja7JNsV3cNeUBsnMBKIwfiqF/p5dR+
t7QjTMCPyDLsfy1RC0V4QA3PYydw/x7n6+dLkhheBA8NnpPw8AxzFhKX1r/U5fE0
nMroAJkr1eILDDmDj5bYzEcXc0+BJB8jE8rRagSF7yqPI2fgpe0=
=GNPR
-----END PGP SIGNATURE-----

--=-Oye7FizEujPvjoRoaaym--
