From: Leonardo Uzcudun <uzcudunl@yahoo.it>
Subject: Re: VLAN 1 - Native
Date: Wed, 1 Feb 2012 11:24:09 +0000 (GMT)
Message-ID: <1328095449.75127.YahooMailNeo@web29014.mail.ird.yahoo.com>
References: <1328095366.10975.YahooMailNeo@web29004.mail.ird.yahoo.com>
Reply-To: Leonardo Uzcudun <uzcudunl@yahoo.it>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nm25-vm4.bullet.mail.ird.yahoo.com ([212.82.109.205]:36180 "HELO
	nm25-vm4.bullet.mail.ird.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1754204Ab2BALaR convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Feb 2012 06:30:17 -0500
In-Reply-To: <1328095366.10975.YahooMailNeo@web29004.mail.ird.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

________________________________
Da: Leonardo Uzcudun <uzcudunl@yahoo.it>
A: "netdev@vger.kernel.org" <netdev@vger.kernel.org>=20
Inviato: Mercoled=EC 1 Febbraio 2012 12:22
Oggetto: VLAN 1 - Native

Hello:

I'm connecting my Linux computer (debian 2.6.32-5) to a switch to imple=
ment vlans.

All is working fine except for the VLAN 1. Of sure you are aware of thi=
s situation and i would like to knoe if there is any parameter or setti=
ng that i should set in the vlan (linux side, not switch) configuration=
=2E Here's my configuration:
ip addr add 0.0.0.0 dev eth0
ip link set eth0 up
ip link add link eth0 name eth0.1 type vlan id 1
ip link add link eth0 name eth0.101 type vlan id 101
ip addr add 0.0.0.0 dev eth0.1
ip addr add 0.0.0.0 dev eth0.101
ip link set eth0.101 up
ip link set eth0.1 up
brctl addbr br_vlan_1
brctl addbr br_vlan_101
brctl addif br_vlan_1 eth0.1
brctl addif br_vlan_101 eth0.101
ip addr add 0.0.0.0 dev br_vlan_1
ip
addr add 0.0.0.0 dev br_vlan_101
ip link set br_vlan_1 up
ip link set br_vlan_101 up

Traffic on vlan 101 is working fine. Traffic on VLAN 1 is not working c=
ause the packets are going out from eth0 like tagged. How could i set t=
he VID 1 as untagged?

Thanks a lot.

BR,

Leo
