From: Ben Greear <greearb@candelatech.com>
Subject: Re: How to count tx and rx bytes?
Date: Tue, 16 Dec 2003 11:38:40 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3FDF5F40.9060609@candelatech.com>
References: <3FDE13AE.3050402@candelatech.com>	<20031216143816.A1546@sygehus.dk> <20031216074520.40f59afd.rddunlap@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Rask Ingemann Lambertsen <rask@sygehus.dk>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "Randy.Dunlap" <rddunlap@osdl.org>
In-Reply-To: <20031216074520.40f59afd.rddunlap@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Randy.Dunlap wrote:
> On Tue, 16 Dec 2003 14:38:16 +0100 Rask Ingemann Lambertsen <rask@sygehus.dk> wrote:
> 
> | On Mon, Dec 15, 2003 at 12:03:58PM -0800, Ben Greear wrote:
> | > 
> | > Is there an agreed upon standard for exactly what ethernet drivers
> | > should be counting for rx-bytes and tx-bytes?  For example, should the
> | > counters include the 4-byte FCS?  Should they include the ethernet header?
> | 
> | Should they include the frame padding in tx-bytes? Some do, some don't.
> | IMHO they should, because you do actually transmit those bytes on the wire.
> 
> If you are referring to padding that is put there by software,
> then Yes.

The padding is often done in the NIC itself, and since the bytes are put
on the wire, they should be counted...

> 
> --
> ~Randy
> 


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
