From: Ben Greear <greearb@candelatech.com>
Subject: Re: VLAN patches
Date: Sat, 05 Oct 2002 12:27:15 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3D9F3D13.3080904@candelatech.com>
References: <3D980A10.8B06F2C2@ebc.ericsson.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: quoted-printable
Cc: netdev@oss.sgi.com, "David S. Miller" <davem@redhat.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: =?ISO-8859-1?Q?Andersson_Bj=F6rn?= <Bjorn.Andersson@ebc.ericsson.se>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This patch looks good too, though the (vlan_id < 0) test
is redundant since vlan_id is an unsigned number.  For
clarity of code, I wouldn't mind if it stayed in though.

Andersson Bj=F6rn wrote:
> Hi,
> I hope you are the right receiver of 8021q-patches.
> We are running SuSe 8.0, i.e kernel 2.4.18.

> - If we try to remove a vlan with VID 0, ifconfig stops working
> completly.
> We fixed it with vlan.c.patch.
>=20
>=20
>=20
>=20
> -----------------------------------------------------------------------=
-
>=20
> --- linux-2.4.18.SuSE/net/8021q/vlan.c.orig	Wed Mar 27 13:57:17 2002
> +++ linux-2.4.18.SuSE/net/8021q/vlan.c	Wed Sep 18 13:19:13 2002
> @@ -207,7 +207,7 @@
>  #endif
> =20
>  	/* sanity check */
> -	if ((vlan_id >=3D VLAN_VID_MASK) || (vlan_id <=3D 0))
> +	if ((vlan_id >=3D VLAN_VID_MASK) || (vlan_id < 0))
>  		return -EINVAL;
> =20
>  	spin_lock_bh(&vlan_group_lock);


--=20
Ben Greear <greearb@candelatech.com>       <Ben_Greear AT excite.com>
President of Candela Technologies Inc      http://www.candelatech.com
ScryMUD:  http://scry.wanfear.com     http://scry.wanfear.com/~greear
