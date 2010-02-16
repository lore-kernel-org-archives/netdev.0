From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: Re: Re: Re: [PATCH 18/23 v3] mlx4_core: Managing common port
Date: Tue, 16 Feb 2010 17:38:14 +0200
Message-ID: <4B7ABBE6.1010506@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: yevgenyp@mellanox.co.il, Roland Dreier <rdreier@cisco.com>,
	netdev@vger.kernel.org, tziporet@mellanox.co.il,
	liranl@mellanox.co.il
To: or.gerlitz@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.mellanox.co.il ([194.90.237.43]:57174 "EHLO mellanox.co.il"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S932451Ab0BPPiR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Feb 2010 10:38:17 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sunday -10,January,-28163 09:59 PM, Or Gerlitz [or.gerlitz@gmail.com] wrote:
> On Wed, Feb 10, 2010 at 7:22 PM, Yevgeny Petrilin <yevgenyp@mellanox.co.il> wrote:
>> On Sunday -10,January,-28163 09:59 PM, Or Gerlitz [or.gerlitz@gmail.com] wrote:
> 
>> The multicast bloom filter is a false-positive filter per port.
>> All multicast packets go through the Multicast tables mechanism where 
>> every PF/VF is registered for every multicast address
> 
> okay, so the bloom filter is going and exact match is coming, understood.
> 
> 
>>> As for the false-positive vlan filter, I understand that this means 
>>> further filtering has to be applied by some driver. Where you thinking on the 802q driver? what about the case where a VF driver is assigned a vlan, does the mlx4 VF code does filtering?
> 
>> The deal with the VLAN filter is similar, it includes all VIDs that some PF/VF requested.
> 
> So for a given VID, a unicast packet carrying it will be dispatched to all the PFs/VFs which have registered this VID? I guess this isn't the case, so please elaborate.
No, this is not the case. My statement says that the VLAN filter became false positive as well.
Dispatching of packet is done by its destination Mac and not VID.
We will add support for dispatching packets by Mac+VID soon.
> 
>> We plan to add a MAC+VLAN filter implementation, that would cancel the need in this filter.
> 
> I'm still not clear in what level you expect the software  filtering to happen
HW filtering, the SW configures the filter.

Yevgeny

