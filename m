From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] net: release dst entry in dev_hard_start_xmit()
Date: Tue, 12 May 2009 21:44:52 +0200
Message-ID: <4A09D1B4.7070509@cosmosbay.com>
References: <49C380A6.4000904@cosmosbay.com> <4A092F59.7020900@cosmosbay.com> <4A093178.9020105@cosmosbay.com> <20090512192748.GA2757@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw2.cosmosbay.com ([86.64.20.130]:53459 "EHLO gw2.cosmosbay.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751075AbZELTpE convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 May 2009 15:45:04 -0400
In-Reply-To: <20090512192748.GA2757@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski a =E9crit :
> On Tue, May 12, 2009 at 10:21:12AM +0200, Eric Dumazet wrote:
>> Eric Dumazet a =E9crit :
> ...
>>> List of devices that must clear this flag is :
>>>
>>> - loopback device, because it calls netif_rx() and quoting Patrick =
:
>>>     "ip_route_input() doesn't accept loopback addresses, so loopbac=
k packets
>>>      already need to have a dst_entry attached."
>>> - appletalk/ipddp.c : needs skb->dst in its xmit function
>>>
>>> - And all devices that call again dev_queue_xmit() from their xmit =
function
>>> (as some classifiers need skb->dst) : bonding, macvlan, eql, ifb, h=
dlc_fr
>=20
> Why not vlan (and/or maybe others in net/ using dev_queue_xmit)?
>=20

Yes I spoted vlan earlier this afternoon.

=46or other net/*, I didnt not find candidates yet.


