From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][BNX2X] round three
Date: Mon, 15 Oct 2007 12:42:05 -0700 (PDT)
Message-ID: <20071015.124205.98881309.davem@davemloft.net>
References: <1192462049.29746.158.camel@eliezer>
	<20071015160512.GA15178@one.firstfloor.org>
	<1192465323.29746.170.camel@eliezer>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andi@firstfloor.org, netdev@vger.kernel.org, jeff@garzik.org,
	mchan@broadcom.com
To: eliezert@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35813
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756276AbXJOTmB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Oct 2007 15:42:01 -0400
In-Reply-To: <1192465323.29746.170.camel@eliezer>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Eliezer Tamir" <eliezert@broadcom.com>
Date: Mon, 15 Oct 2007 18:22:03 +0200

> On Mon, 2007-10-15 at 18:05 +0200, Andi Kleen wrote:
> > > This is not a driver issue.
> > > Unfortunately, the firmware code is different for LE and BE machines.
> > > We had issues with the BE firmware that appear to be resolved.
> > > Hopefully, the next version will have both.
> > 
> > If the firmware is big it might be better to just add the necessary
> > conversions to the driver and always use BE. Endian conversions
> > tend to be very cheap.
> 
> For a given architecture, only the right version of the microcode is
> compiled, so the binary only contains one copy of the microcode.

But it still takes up source tree space.

> The good news is that future versions of the device will not have this
> issue.
> 

The better news is that you only need the little-endian firmware
even with these chips, simple assume little-endian for all
chip shared data-structures and swap in the driver as we've
explained to you.

The cost for big-endian cpus is almost nothing.
