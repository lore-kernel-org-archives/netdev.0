From: Ben Greear <greearb@candelatech.com>
Subject: Re: VLAN patches
Date: Sat, 05 Oct 2002 12:23:36 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3D9F3C38.6060608@candelatech.com>
References: <3D980A10.8B06F2C2@ebc.ericsson.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: quoted-printable
Cc: netdev@oss.sgi.com, "David S. Miller" <davem@redhat.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: =?ISO-8859-1?Q?Andersson_Bj=F6rn?= <Bjorn.Andersson@ebc.ericsson.se>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Dave, please apply this patch if you haven't already,
it seems correct to me.

Andersson Bj=F6rn wrote:
> Hi,
> I hope you are the right receiver of 8021q-patches.
> We are running SuSe 8.0, i.e kernel 2.4.18.
>=20
> - When addding several egress-mappings we get stuck in an eternal
> loop if they end up in the same hash-bucket, see vlan_dev.c.path.

> -----------------------------------------------------------------------=
-
>=20
> --- linux-2.4.18.SuSE/net/8021q/vlan_dev.c.orig	Wed Mar 27 13:57:17 200=
2
> +++ linux-2.4.18.SuSE/net/8021q/vlan_dev.c	Wed Sep 18 13:19:52 2002
> @@ -570,6 +570,7 @@
>  					dev_put(dev);
>  					return 0;
>  				}
> +				mp =3D mp->next;
>  			}
> =20
>  			/* Create a new mapping then. */


--=20
Ben Greear <greearb@candelatech.com>       <Ben_Greear AT excite.com>
President of Candela Technologies Inc      http://www.candelatech.com
ScryMUD:  http://scry.wanfear.com     http://scry.wanfear.com/~greear
