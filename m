From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: VLAN 1 - Native
Date: Wed, 01 Feb 2012 18:21:21 +0100
Message-ID: <1328116881.1882.14.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <1328095366.10975.YahooMailNeo@web29004.mail.ird.yahoo.com>
	 <1328095449.75127.YahooMailNeo@web29014.mail.ird.yahoo.com>
	 <1328101484.2595.17.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <CADDf=MQ8EYEtOO2e5NJLrW0DKDz5xCBEBwuY6rxNu4Cybq=kKQ@mail.gmail.com>
	 <CADDf=MQ=0eadY-zT_YAgp17fo_xRUh0dg6nHCLpNXcMQnUdyCQ@mail.gmail.com>
	 <1328108723.2595.33.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <CADDf=MRDa6C47ToCnR3_cTkfJR8VL9UAScwzwGVUDn3O4nL6fA@mail.gmail.com>
	 <1328114680.76107.YahooMailNeo@web29019.mail.ird.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: yao zhao <yao.development@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Leonardo Uzcudun <uzcudunl@yahoo.it>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:40312 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752904Ab2BARVY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Feb 2012 12:21:24 -0500
Received: by wics10 with SMTP id s10so1086641wic.19
        for <netdev@vger.kernel.org>; Wed, 01 Feb 2012 09:21:23 -0800 (PST)
In-Reply-To: <1328114680.76107.YahooMailNeo@web29019.mail.ird.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 01 f=C3=A9vrier 2012 =C3=A0 16:44 +0000, Leonardo Uzcudun a=
 =C3=A9crit :
> I'm sorry guys but i'm not understanding. Allow me to ask in a
> different way.
>=20
> I've a linux computer with 3 network cards (eth0, eth1 and eth2)
>=20
> eth0 is connected to a switch with vlans config.
> eth1 is connected to a network that has VID 1
> eth2 is connected to a network that has VID 101
>=20
> I've the following configuration:
>=20
> ip addr add 0.0.0.0 dev eth0
> ip link set eth0 up
> ip link add link eth0 name eth0.1 type vlan id 1
> ip link add link eth0 name eth0.101 type vlan id 101
> ip addr add 0.0.0.0 dev eth0.1
> ip addr add 0.0.0.0 dev eth0.101
> ip link set eth0.101 up
> ip link set eth0.1 up
> brctl addbr br_vlan_1
> brctl addbr br_vlan_101
> brctl addif br_vlan_1 eth0.1 eth1
> brctl addif br_vlan_101 eth0.101 eth2
> ip addr add 0.0.0.0 dev br_vlan_1
> ip addr add 0.0.0.0 dev br_vlan_101
> ip link set br_vlan_1 up
> ip link set br_vlan_101 up
>=20
>=20
> with this setup, the traffic on VID 101 is working fine. The devices
> across the switch and eth2 communicate each other but, the devices on
> VID 1 don't communicate with those connected to eth1
>=20
> If I remove eth0.1 and add eth0 to br_vlan_1 i have the opposite
> situation:
> the traffic on VID 101 is NOT working. The devices across the switch
> and eth2 DO NOT communicate each other
> but, the devices on VID 1 communicate with those connected to eth1. O=
f
> course on br_vlan_1 i'm getting the VID 1 traffic AND the VID 101....


This might work on recent kernels, please try them.

This is netdev list, after all ;)
