From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] IPROUTE: Modify tc for new PRIO multiqueue behavior
Date: Fri, 04 May 2007 13:06:19 -0700 (PDT)
Message-ID: <20070504.130619.99203618.davem@davemloft.net>
References: <1178109829.4074.48.camel@localhost>
	<D5C1322C3E673F459512FB59E0DDC32902C70A5C@orsmsx414.amr.corp.intel.com>
	<20070504130110.0694aee6@freekitty>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peter.p.waskiewicz.jr@intel.com, hadi@cyberus.ca, kaber@trash.net,
	netdev@vger.kernel.org, jgarzik@pobox.com, cramerj@intel.com,
	auke-jan.h.kok@intel.com, christopher.leech@intel.com
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37646
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1161568AbXEDUGd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 May 2007 16:06:33 -0400
In-Reply-To: <20070504130110.0694aee6@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Fri, 4 May 2007 13:01:10 -0700

> Just because they want to standardize, and put it in hardware doesn't
> mean it is a good idea and Linux needs to support it!
> 
> Why is it better for hardware to make the "next packet to send" decision?
> For wired ethernet, I can't see how adding the complexity of fixed number
> of small queues is a gain. Better to just do the priority decision in software
> and then queue it to the hardware. This seems like the old Token Ring
> and MAP/TOP style crap crammed on top of Ethernet.

I suspect perhaps the real impetus behind this facility is not being
disclosed.

It certainly is not going to be faster to do this in hardware.

I myself don't see why in the world one would want to do this in
hardware either.  Software can do the selection fast enough and with
tons more flexibility.
