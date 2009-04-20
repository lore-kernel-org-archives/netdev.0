From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: bond interface arp, vlan and trunk / network question
Date: Mon, 20 Apr 2009 20:16:16 +0200
Message-ID: <49ECBBF0.80202@cosmosbay.com>
References: <1ef444010904201050g72651387se3feca3fbd68ce30@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org,
	Linux Netdev List <netdev@vger.kernel.org>
To: stefan novak <lms.brubaker@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:45047 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752263AbZDTSQX convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Apr 2009 14:16:23 -0400
In-Reply-To: <1ef444010904201050g72651387se3feca3fbd68ce30@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

stefan novak a =E9crit :
> Hello list,
>=20
> I've got a Problem with my bladecenter and bond interfaces.
> My Server has 2 interface, each on a seperate switch. Each
> serverinterface is connected via a trunk to one of the switches.
> Each switch has a trunk to stacked-backbone switch.
>=20
> nic1 --trunk--> bladesw1 --trunk--> backbone switch
> nic2 --trunk--> bladesw2 --trunk--> backbone switch
>=20
> So far vlan and trunking works as expected. But if one trunk
> connection from a bladeswitch to the backbone switch is down the
> mii-tool cant recognize this.

What is the exact problem on this one ?

> I tried to use an arp target on the backbone switch to check the
> connection state.
>=20
> Now i'm running into problems. :(
> My bladesw1 is configured with a trunk and a private vlan id of 600.
> On the backbone switch is a server in the vlan 600 connected, but i
> can't get an arp request.
>=20
> What can be the problem, or is it possible to add a vlan tag on the a=
rp check?
>=20

What driver is in use on your NIC interface ?

Could you post your bonding settings ?

cat /proc/net/bonding/bond0


