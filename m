From: "Thomas 'Dent' Mirlacher" <dent@cosy.sbg.ac.at>
Subject: Re: [Fwd: IPoIB]
Date: Thu, 6 Jun 2002 21:32:32 +0200 (MET DST)
Sender: owner-netdev@oss.sgi.com
Message-ID: <Pine.GSO.4.05.10206062126130.19900-100000@mausmaki.cosy.sbg.ac.at>
References: <3CFFB4A2.E9FC09FC@vieo.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com, jeff young <jsy@vieo.com>,
   gary klesk <gklesk@vieo.com>
Return-path: <owner-netdev@oss.sgi.com>
To: Joseph Golio <golio@vieo.com>
In-Reply-To: <3CFFB4A2.E9FC09FC@vieo.com>
List-Id: netdev.vger.kernel.org

--snip/snip

> The more I dig into this, the more I figure out that the
> problem is larger than I though. Not only do I need to increase the size of a
> hardware address, I also need to provide a new interface service routine to
> allow the device driver to lookup/translate a portion of the hardware address
> and return more information that needs to go into the ARP cache.
> 
> Specifically, the IETF IPoIB group has defined an Infiniband hardware
> address to have 1 byte of reserved, 3 bytes of Queue Pair Number (QPN) and
> 16 bytes of Global Identifier (GID). Unfortunately, in order to build the
> hardware header in packets to send, another piece of information is needed
> -- that being the Local
> Identifier (LID). If the LID is kept in the ARP cache, then it will be readily
> available from "arp_find()" at the time of transmission.

> If we don't do that, we would have to
> have a separate table and mechanism in the driver to map from
> QPN/GID ===> LID.
> I would rather not do that if I didn't have to. It seems fundamental
> (at least to me) that everything one needs to build the hardware header
> (at least everything that is related
> specifically to the destination) should be stored in the ARP cache.

you can already do that, since you will save everything in the arp
cache which is the size of dev->addr_len. - did i miss the point?

cheers,

	tm

-- 
in some way i do, and in some way i don't.
