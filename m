From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: Re: am335x: no multicast reception over VLAN
Date: Tue, 5 Apr 2016 11:41:53 +0530
Message-ID: <57035729.8050704@ti.com>
References: <CAGm1_ktOqB4QBMy2G4XeHTkaP+WvG8GOc8maVv3dDoxM+-F+ZA@mail.gmail.com>
 <56F9FDD0.8030504@ti.com>
 <CAGm1_ksxRPCAqx4n5gbsARSYeF116BT7r8cC6=1QYnEsYRxpVw@mail.gmail.com>
 <56FA616C.9080502@ti.com>
 <CAGm1_ksvEdk-mF-hW4o5+bri6J6sMgnQQVD3j-e7xm6PsP8k0A@mail.gmail.com>
 <56FA78AA.4030402@ti.com> <56FB6543.9060904@ti.com>
 <CAGm1_kvXA4egrK8-oCedYjvPm7BhJdy_w-5ON24snYdKiN3K7g@mail.gmail.com>
 <56FC0431.5000106@ti.com> <878u0z9297.fsf@dell.be.48ers.dk>
 <56FCC59B.70209@ti.com>
 <CAGm1_kutVn+jNf58QwKyO8j5NmRhaOCUsXmpTiLbX75AczCm6w@mail.gmail.com>
 <56FE64EE.6050701@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Peter Korsgaard <peter@korsgaard.com>,
	netdev <netdev@vger.kernel.org>,
	"linux-omap@vger.kernel.org" <linux-omap@vger.kernel.org>,
	<drivshin@allworx.com>, <ml@markusgrimm.de>,
	David Miller <davem@davemloft.net>
To: Grygorii Strashko <grygorii.strashko@ti.com>,
	Yegor Yefremov <yegorslists@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bear.ext.ti.com ([192.94.94.41]:60387 "EHLO bear.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751702AbcDEGMQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Apr 2016 02:12:16 -0400
In-Reply-To: <56FE64EE.6050701@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 01 April 2016 05:39 PM, Grygorii Strashko wrote:
> On 03/31/2016 10:52 AM, Yegor Yefremov wrote:
>> On Thu, Mar 31, 2016 at 8:37 AM, Mugunthan V N <mugunthanvnm@ti.com>=
 wrote:
>>> On Thursday 31 March 2016 01:17 AM, Peter Korsgaard wrote:
>>>>>>>>> "Mugunthan" =3D=3D Mugunthan V N <mugunthanvnm@ti.com> writes=
:
>>>>
>>>> Hi,
>>>>
>>>>   > You had received these packets as tcpdump will enable promiscu=
ous mode
>>>>   > so that you receive all the packets from the wire.
>>>>
>>>> FYI, you can use the -p option to tcpdump to not put the interface=
 into
>>>> promiscuous mode.
>>>>
>>>
>>> Thanks for the information Peter Korsgaard.
>>>
>>> Yegor, can you provide tcpdump using -p as well in Grygorii command=
s.
>>
>> Before VLAN configuration:
>>
>> # switch-config -d
>> cpsw hw version 1.12 (0)
>> 0   : type: vlan , vid =3D 1, untag_force =3D 0x3, reg_mcast =3D 0x3=
,
>> unreg_mcast =3D 0x0, member_list =3D 0x3
>> 1   : type: mcast, vid =3D 1, addr =3D ff:ff:ff:ff:ff:ff, mcast_stat=
e =3D f,
>> no super, port_mask =3D 0x3
>> 2   : type: ucast, vid =3D 1, addr =3D 74:6a:8f:00:16:12, ucast_type=
 =3D
>> persistant, port_num =3D 0x0, Secure
>> 3   : type: vlan , vid =3D 0, untag_force =3D 0x7, reg_mcast =3D 0x0=
,
>> unreg_mcast =3D 0x0, member_list =3D 0x7
>> 4   : type: mcast, vid =3D 1, addr =3D 01:00:5e:00:00:01, mcast_stat=
e =3D f,
>> no super, port_mask =3D 0x3
>> 5   : type: vlan , vid =3D 2, untag_force =3D 0x5, reg_mcast =3D 0x5=
,
>> unreg_mcast =3D 0x0, member_list =3D 0x5
>> 6   : type: mcast, vid =3D 2, addr =3D ff:ff:ff:ff:ff:ff, mcast_stat=
e =3D f,
>> no super, port_mask =3D 0x5
>> 7   : type: ucast, vid =3D 2, addr =3D 74:6a:8f:00:16:13, ucast_type=
 =3D
>> persistant, port_num =3D 0x0, Secure
>> 8   : type: mcast, vid =3D 2, addr =3D 01:00:5e:00:00:01, mcast_stat=
e =3D f,
>> no super, port_mask =3D 0x5
>>
>> After VLAN configuration:
>>
>> # switch-config -d
>> cpsw hw version 1.12 (0)
>> 0   : type: vlan , vid =3D 1, untag_force =3D 0x3, reg_mcast =3D 0x3=
,
>> unreg_mcast =3D 0x0, member_list =3D 0x3
>> 1   : type: mcast, vid =3D 1, addr =3D ff:ff:ff:ff:ff:ff, mcast_stat=
e =3D f,
>> no super, port_mask =3D 0x3
>> 2   : type: ucast, vid =3D 1, addr =3D 74:6a:8f:00:16:12, ucast_type=
 =3D
>> persistant, port_num =3D 0x0, Secure
>> 3   : type: vlan , vid =3D 0, untag_force =3D 0x7, reg_mcast =3D 0x0=
,
>> unreg_mcast =3D 0x0, member_list =3D 0x7
>> 4   : type: mcast, vid =3D 1, addr =3D 01:00:5e:00:00:01, mcast_stat=
e =3D f,
>> no super, port_mask =3D 0x3
>> 5   : type: vlan , vid =3D 2, untag_force =3D 0x5, reg_mcast =3D 0x5=
,
>> unreg_mcast =3D 0x0, member_list =3D 0x5
>> 6   : type: mcast, vid =3D 2, addr =3D ff:ff:ff:ff:ff:ff, mcast_stat=
e =3D f,
>> no super, port_mask =3D 0x5
>> 7   : type: ucast, vid =3D 2, addr =3D 74:6a:8f:00:16:13, ucast_type=
 =3D
>> persistant, port_num =3D 0x0, Secure
>> 8   : type: mcast, vid =3D 2, addr =3D 01:00:5e:00:00:01, mcast_stat=
e =3D f,
>> no super, port_mask =3D 0x5
>> 9   : type: vlan , vid =3D 100, untag_force =3D 0x0, reg_mcast =3D 0=
x5,
>> unreg_mcast =3D 0x0, member_list =3D 0x5
>> 10  : type: ucast, vid =3D 100, addr =3D 74:6a:8f:00:16:13, ucast_ty=
pe =3D
>> persistant, port_num =3D 0x0
>> 11  : type: mcast, vid =3D 100, addr =3D ff:ff:ff:ff:ff:ff, mcast_st=
ate =3D
>> f, no super, port_mask =3D 0x5
>> 12  : type: mcast, vid =3D 2, addr =3D 01:80:c2:00:00:21, mcast_stat=
e =3D f,
>> no super, port_mask =3D 0x5
>>
>> During mulitcast receive:
>>
>> # switch-config -d
>> cpsw hw version 1.12 (0)
>> 0   : type: vlan , vid =3D 1, untag_force =3D 0x3, reg_mcast =3D 0x3=
, unreg_mcast =3D 0x0, member_list =3D 0x3
>> 1   : type: mcast, vid =3D 1, addr =3D ff:ff:ff:ff:ff:ff, mcast_stat=
e =3D f, no super, port_mask =3D 0x3
>> 2   : type: ucast, vid =3D 1, addr =3D 74:6a:8f:00:16:12, ucast_type=
 =3D persistant, port_num =3D 0x0, Secure
>> 3   : type: vlan , vid =3D 0, untag_force =3D 0x7, reg_mcast =3D 0x0=
, unreg_mcast =3D 0x0, member_list =3D 0x7
>=20
> unreg_mcast =3D 0x0 means unregistered multicast packets will be drop=
ped
>=20
>> 4   : type: mcast, vid =3D 1, addr =3D 01:00:5e:00:00:01, mcast_stat=
e =3D f, no super, port_mask =3D 0x3
>> 5   : type: vlan , vid =3D 2, untag_force =3D 0x5, reg_mcast =3D 0x5=
, unreg_mcast =3D 0x0, member_list =3D 0x5
>=20
> unreg_mcast =3D 0x0=20
>=20
>> 6   : type: mcast, vid =3D 2, addr =3D ff:ff:ff:ff:ff:ff, mcast_stat=
e =3D f, no super, port_mask =3D 0x5
>> 7   : type: ucast, vid =3D 2, addr =3D 74:6a:8f:00:16:13, ucast_type=
 =3D persistant, port_num =3D 0x0, Secure
>> 8   : type: mcast, vid =3D 2, addr =3D 01:00:5e:00:00:01, mcast_stat=
e =3D f, no super, port_mask =3D 0x5
>> 9   : type: vlan , vid =3D 100, untag_force =3D 0x0, reg_mcast =3D 0=
x5, unreg_mcast =3D 0x0, member_list =3D 0x5
>=20
> unreg_mcast =3D 0x0=20
>=20
>> 10  : type: ucast, vid =3D 100, addr =3D 74:6a:8f:00:16:13, ucast_ty=
pe =3D persistant, port_num =3D 0x0
>> 11  : type: mcast, vid =3D 100, addr =3D ff:ff:ff:ff:ff:ff, mcast_st=
ate =3D f, no super, port_mask =3D 0x5
>> 12  : type: mcast, vid =3D 2, addr =3D 01:80:c2:00:00:21, mcast_stat=
e =3D f, no super, port_mask =3D 0x5
>> 13  : type: mcast, vid =3D 2, addr =3D 01:00:5e:03:1d:47, mcast_stat=
e =3D f, no super, port_mask =3D 0x5
>=20
> This is requested mcast address, but it's registered for vid=3D2 (pro=
pagated through .ndo_set_rx_mode())
>=20
>> 14  : type: ucast, vid =3D 100, addr =3D 66:22:04:bc:90:26, ucast_ty=
pe =3D untouched , port_num =3D 0x2
>=20
> [...]
>>
>> Both tcpdumps with -p option showed no packets. If I execute ping, I
>> can see related ICMP packets. addr =3D 66:22:04:bc:90:26 is PandaBoa=
rds
>> MAC.
>>
>> Btw I've attached my test scripts (mcastr.py - multicast receiver an=
d
>> mcastt.py - multicast transmitter). Could you reproduce my setup?
>>
>=20
> I was able to reproduce an issue with your script. As I understand, w=
hen cpsw receive the
> mcast packet with dst_address=3D01:00:5e:03:1d:47 and vid=3D100 it hi=
ts
> the case:
> "if (Multicast packet) # destination address not found
> then portmask is the logical =93AND=94 of unreg_mcast_flood_mask and =
vlan_member_list
> then goto Egress process"
>=20
> and as result packet is dropped (you can check eth1 statistic # ethto=
ol -S eth1).
>=20
> Unfortunately, I was no able to configure mcast address properly in d=
ual mac mode :(,
> but probably Mugunthan can comment here - mcast addressess are offloa=
ded to cpsw from

I was able to add mcast address for eth0/eth1, but not finding a way to
add mcast entries to eth1.100 interface. I gone through Linux network
stack and didn't find a way where stack asks the driver to add mcast
address for vlan interfaces. *_Network Experts_* can help us here.

> Net core through  .ndo_set_rx_mode() and struct netdev_hw_addr doesn'=
t contain any
> information about vlan and cpsw uses default port vlan, which is vid=3D=
2 for eth1 in=20
> dual mac mode.
> =20
>=20
>=20
> As W/A the allmulti flag can be used:
>=20
> # ifconfig eth1.100 allmulti=20

=46or now this is the only possible option that can be used.

Regards
Mugunthan V N
