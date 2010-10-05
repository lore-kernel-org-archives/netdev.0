From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] skge: add quirk to limit DMA
Date: Tue, 05 Oct 2010 15:09:41 -0700 (PDT)
Message-ID: <20101005.150941.267944554.davem@davemloft.net>
References: <20100929092515.GA6804@redhat.com>
	<20101005.001800.13732127.davem@davemloft.net>
	<20101006065845.5759dbeb@s6510>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sgruszka@redhat.com, netdev@vger.kernel.org, luya@fedoraproject.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47182
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754258Ab0JEWJU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Oct 2010 18:09:20 -0400
In-Reply-To: <20101006065845.5759dbeb@s6510>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Wed, 6 Oct 2010 06:58:45 +0900

> On Tue, 05 Oct 2010 00:18:00 -0700 (PDT)
> David Miller <davem@davemloft.net> wrote:
> 
>> From: Stanislaw Gruszka <sgruszka@redhat.com>
>> Date: Wed, 29 Sep 2010 11:33:23 +0200
>> 
>> > Skge devices installed on some Gigabyte motherboards are not able to
>> > perform 64 dma correctly due to board PCI implementation, so limit
>> > DMA to 32bit if such boards are detected.
>> > 
>> > Bug was reported here:
>> > https://bugzilla.redhat.com/show_bug.cgi?id=447489
>> > 
>> > Signed-off-by: Stanislaw Gruszka <sgruszka@redhat.com>
>> > Tested-by: Luya Tshimbalanga <luya@fedoraproject.org>
>> 
>> Stephen?  Can I get an ACK or some kind of other status on this?
> 
> I was hoping to find the hardware somewhere to dig deeper into
> this. But until I know more please apply the patch. There are
> two possibilities that still exist, 1) it is true for all devices
> on this motherboard (in which cases it should be a PCI quirk),
> 2) it is a driver bug. The test was going to be putting a skge
> pci card in a slot on the MB.

Ok, thanks Stephen, I'll apply his patch for now.
