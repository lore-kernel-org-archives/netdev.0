From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] ne: DeviceTree support.
Date: Mon, 18 Jan 2016 11:51:39 -0500 (EST)
Message-ID: <20160118.115139.619226125906732902.davem@davemloft.net>
References: <20160116172226.GB9880@lunn.ch>
	<87d1szmki3.wl-ysato@users.sourceforge.jp>
	<20160118150834.GC923@lunn.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ysato@users.sourceforge.jp, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: andrew@lunn.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40483 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755761AbcARQvk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jan 2016 11:51:40 -0500
In-Reply-To: <20160118150834.GC923@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Lunn <andrew@lunn.ch>
Date: Mon, 18 Jan 2016 16:08:34 +0100

> On Mon, Jan 18, 2016 at 04:09:40PM +0900, Yoshinori Sato wrote:
>> On Sun, 17 Jan 2016 02:22:26 +0900,
>> Andrew Lunn wrote:
>> > 
>> > On Sat, Jan 16, 2016 at 01:19:45AM +0900, Yoshinori Sato wrote:
>> > > Add basic device tree support.
>> > > 
>> > > Signed-off-by: Yoshinori Sato <ysato@users.sourceforge.jp>
>> > > ---
>> > >  Documentation/devicetree/bindings/net/ne2000.txt | 17 +++++++++++++++++
>> > >  drivers/net/ethernet/8390/ne.c                   | 20 +++++++++++++++++++-
>> > >  2 files changed, 36 insertions(+), 1 deletion(-)
>> > >  create mode 100644 Documentation/devicetree/bindings/net/ne2000.txt
>> > > 
>> > > diff --git a/Documentation/devicetree/bindings/net/ne2000.txt b/Documentation/devicetree/bindings/net/ne2000.txt
>> > > new file mode 100644
>> > > index 0000000..8b0dfbf
>> > > --- /dev/null
>> > > +++ b/Documentation/devicetree/bindings/net/ne2000.txt
>> > > @@ -0,0 +1,17 @@
>> > > +NE2000 compatible network controller
>> > > +
>> > > +Required properties:
>> > > +- compatible: "national,ne2000"
>> > > +- reg: base address and length of NE2000.
>> > > +- interrupts: interrupt specifier for the sole interrupt.
>> > > +- national,dcr: DCR setting value.
>> > 
>> > You say here that national,dcr is required, yet the code to read it is
>> > not returning an error if it is missing.
>> 
>> Yes. This value required. Missing error check.
>> 
>> > Also, what is DCR?
>> 
>> This is chip configuration.
>> It value depend on target design.
> 
> It needs to be described in detail what it is. Device tree bindings
> generally don't list values to be poked into registers. They describe
> something, and from that, the value to be poked into a register is
> derived.

Agreed.
