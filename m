From: Patrick McHardy <kaber@trash.net>
Subject: Re: [patch net-next-2.6] net: make dev->master general
Date: Mon, 14 Feb 2011 17:27:06 +0100
Message-ID: <4D5957DA.3020303@trash.net>
References: <20110212164836.GB12156@psychotron.redhat.com> <4D58EC6C.7030005@gmail.com> <20110214090133.GB2746@psychotron.redhat.com> <4D593802.8090508@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jiri Pirko <jpirko@redhat.com>, netdev@vger.kernel.org,
	davem@davemloft.net, shemminger@linux-foundation.org,
	fubar@us.ibm.com, eric.dumazet@gmail.com
To: =?ISO-8859-1?Q?Nicolas_de_Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:56096 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755940Ab1BNQ1I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Feb 2011 11:27:08 -0500
In-Reply-To: <4D593802.8090508@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am 14.02.2011 15:11, schrieb Nicolas de Peslo=FCan:
> Le 14/02/2011 10:01, Jiri Pirko a =E9crit :
>> That is true. I think that it makes no sense to have iface enslaved =
in
>> bond and bridge at the same time. Do you have a scenario where it ma=
kes
>> sense?
>=20
> Agreed for bonding/bridge, because both tend to eat all skb, even if
> bridge has a way to give skb to others, as stated above. Bonding
> might/should do the same.
>=20
> But, for macvlan or vlan for example, it is different. They will igno=
re
> skb not matching the correct dst_mac (macvlan) or vlan_id (vlan) and
> give a chance to other to use the skb.

Both are not slaves of the device, so its not really related to this
patch. Slaves sit below the device, macvlan and vlan sit above the
device. Their link to the "real" device is through ->iflink.
