From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: VLAN 1 - Native
Date: Wed, 01 Feb 2012 14:04:44 +0100
Message-ID: <1328101484.2595.17.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <1328095366.10975.YahooMailNeo@web29004.mail.ird.yahoo.com>
	 <1328095449.75127.YahooMailNeo@web29014.mail.ird.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Leonardo Uzcudun <uzcudunl@yahoo.it>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:42135 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754029Ab2BANEs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Feb 2012 08:04:48 -0500
Received: by wgbdt10 with SMTP id dt10so1265237wgb.1
        for <netdev@vger.kernel.org>; Wed, 01 Feb 2012 05:04:47 -0800 (PST)
In-Reply-To: <1328095449.75127.YahooMailNeo@web29014.mail.ird.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 01 f=C3=A9vrier 2012 =C3=A0 11:24 +0000, Leonardo Uzcudun a=
 =C3=A9crit :
> ________________________________
> Da: Leonardo Uzcudun <uzcudunl@yahoo.it>
> A: "netdev@vger.kernel.org" <netdev@vger.kernel.org>=20
> Inviato: Mercoled=C3=AC 1 Febbraio 2012 12:22
> Oggetto: VLAN 1 - Native
>=20
> Hello:
>=20
> I'm connecting my Linux computer (debian 2.6.32-5) to a switch to
> implement vlans.
>=20
> All is working fine except for the VLAN 1. Of sure you are aware of
> this situation and i would like to knoe if there is any parameter or
> setting that i should set in the vlan (linux side, not switch)
> configuration. Here's my configuration:
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
> brctl addif br_vlan_1 eth0.1
> brctl addif br_vlan_101 eth0.101
> ip addr add 0.0.0.0 dev br_vlan_1
> ip
> addr add 0.0.0.0 dev br_vlan_101
> ip link set br_vlan_1 up
> ip link set br_vlan_101 up
>=20
> Traffic on vlan 101 is working fine. Traffic on VLAN 1 is not working
> cause the packets are going out from eth0 like tagged. How could i se=
t
> the VID 1 as untagged?

What do you mean by "sending packets for VID 1, untagged " ?

What is the difference between vlan 101 and vlan 1 ?
