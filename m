From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: Re: [PATCH 18/23 v3] mlx4_core: Managing common port filters by
Date: Tue, 16 Feb 2010 08:53:47 +0200
Message-ID: <15ddcffd1002152253g2426f3e9l33cdc6b862d7734c@mail.gmail.com>
References: <4B72EB6B.9000708@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Roland Dreier <rdreier@cisco.com>, netdev@vger.kernel.org,
	tziporet@mellanox.co.il, liranl@mellanox.co.il,
	Alex Rosenbaum <alexr@voltaire.com>
To: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f213.google.com ([209.85.218.213]:62796 "EHLO
	mail-bw0-f213.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753917Ab0BPGxy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Feb 2010 01:53:54 -0500
Received: by bwz5 with SMTP id 5so1651540bwz.1
        for <netdev@vger.kernel.org>; Mon, 15 Feb 2010 22:53:52 -0800 (PST)
In-Reply-To: <4B72EB6B.9000708@mellanox.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 10, 2010 at 7:22 PM, Yevgeny Petrilin
<yevgenyp@mellanox.co.il> wrote:
> On Sunday -10,January,-28163 09:59 PM, Or Gerlitz [or.gerlitz@gmail.com] wrote:

> The multicast bloom filter is a false-positive filter per port.
> All multicast packets go through the Multicast tables mechanism where every PF/VF is registered for every multicast address

okay, so the bloom filter is going and exact match is coming, understood.


>> As for the false-positive vlan filter, I understand that this means further filtering has to be applied by some driver. Where you
>> thinking on the 802q driver? what about the case where a VF driver is assigned a vlan, does the mlx4 VF code does filtering?

> The deal with the VLAN filter is similar, it includes all VIDs that some PF/VF requested.

So for a given VID, a unicast packet carrying it will be dispatched to
all the PFs/VFs which
have registered this VID? I guess this isn't the case, so please elaborate.

> We plan to add a MAC+VLAN filter implementation, that would cancel the need in this filter.

I'm still not clear in what level you expect the software  filtering to happen

Or.
