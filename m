From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/4] net/phy/marvell: Expose IDs and flags in a .h and
 add dns323 LEDs setup flag
Date: Mon, 14 Jun 2010 09:13:20 -0700 (PDT)
Message-ID: <20100614.091320.59687255.davem@davemloft.net>
References: <1276391423.1962.263.camel@pasglop>
	<20100613052831.GA17012@pengutronix.de>
	<1276408955.1962.578.camel@pasglop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: w.sang@pengutronix.de, netdev@vger.kernel.org, hvr@gnu.org,
	linux-arm-kernel@lists.infradead.org, nico@fluxnic.net
To: benh@kernel.crashing.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33610
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751401Ab0FNQNJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jun 2010 12:13:09 -0400
In-Reply-To: <1276408955.1962.578.camel@pasglop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Sun, 13 Jun 2010 16:02:35 +1000

> On Sun, 2010-06-13 at 07:28 +0200, Wolfram Sang wrote:
>> On Sun, Jun 13, 2010 at 11:10:23AM +1000, Benjamin Herrenschmidt wrote:
>> > This moves the various known Marvell PHY IDs to include/linux/marvell_phy.h
>> > along with dev_flags definitions for use by the driver.
>> > 
>> > I then added a flag that changes the PHY init code to setup the LEDs
>> > config to the values needed to operate a dns323 rev C1 NAS.
>> > 
>> > I moved the existing "resistance" flag to the .h as well, though I've
>> > been unable to find whoever sets this to convert it to use that constant.
>> > 
>> > Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
>> 
>> That should do for now.
>> 
>> Reviewed-by: Wolfram Sang <w.sang@pengutronix.de>
> 
> Thanks.
> 
> Dave, any objection to having that go via the arm tree along with the
> rest of my patches to support the dns323 since they depend on this one ?

No problem:

Acked-by: David S. Miller <davem@davemloft.net>
