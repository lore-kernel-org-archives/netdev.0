From: Ben Greear <greearb@candelatech.com>
Subject: Re: [VLAN] VLAN patches
Date: Mon, 30 Sep 2002 09:19:39 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3D98799B.9060008@candelatech.com>
References: <D8B86D9BB607124BA1D54EDB7944DB0B140BC4@exchange.mabuhay>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: quoted-printable
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: vlan@Scry.WANfear.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Dave Santucci wrote:
> Bjorn
> 	Since the data type for the vlan_id is specified as an "unsigned short=
",
> 	The comparison (vlan_id < 0) will always be false due to the range of =
the data
>  	type.
>=20
> 	-ds
> =09
>=20
> -----Original Message-----
> From: Andersson Bj=F6rn [mailto:Bjorn.Andersson@ebc.ericsson.se]=20
> Sent: Monday, September 30, 2002 1:24 AM
> To: netdev@oss.sgi.com
> Subject: [VLAN] VLAN patches
>=20
> Hi,
> I hope you are the right receiver of 8021q-patches.
> We are running SuSe 8.0, i.e kernel 2.4.18.
>=20
> - When addding several egress-mappings we get stuck in an eternal
> loop if they end up in the same hash-bucket, see vlan_dev.c.path.
>=20
> - If we try to remove a vlan with VID 0, ifconfig stops working
> completly.
> We fixed it with vlan.c.patch.

Is there any reason to ever let someone add a VLAN of ID 0 in the first p=
lace?

Ben

>=20
>=20


--=20
Ben Greear <greearb@candelatech.com>       <Ben_Greear AT excite.com>
President of Candela Technologies Inc      http://www.candelatech.com
ScryMUD:  http://scry.wanfear.com     http://scry.wanfear.com/~greear
