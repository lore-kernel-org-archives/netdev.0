From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2 0/9] macb: add support for Cadence GEM
Date: Wed, 16 Mar 2011 13:17:34 -0700 (PDT)
Message-ID: <20110316.131734.242138246.davem@davemloft.net>
References: <1300184096-13937-1-git-send-email-jamie@jamieiles.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	nicolas.ferre@atmel.com, plagnioj@jcrosoft.com
To: jamie@jamieiles.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37277
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753969Ab1CPUQ5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Mar 2011 16:16:57 -0400
In-Reply-To: <1300184096-13937-1-git-send-email-jamie@jamieiles.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamie Iles <jamie@jamieiles.com>
Date: Tue, 15 Mar 2011 10:14:47 +0000

> This patch series extends the Atmel MACB driver to support the Cadence
> GEM (Gigabit Ethernet MAC) to support 10/100 operation.  The GEM is
> based on the MACB block but has a few moved registers and bitfields.
> This patch series attempts to use the MACB accessors where block
> functionallity is identical and only overrides to GEM specific
> acccessors when needed.
> 
> This has been runtested on a board with a Cadence GEM and compile tested
> for all at91 configurations and a number of avr32 configurations.
> 
> Changes since v1:
> 	- AT91 now provides a fake "hclk" and "macb_clk" has been
> 	renamed to "pclk" to be consistent with AVR32.
> 	- Configurable GEM receive buffer size support has been added.
> 	- pr_foo() and dev_foo() have been converted to netdev_foo()
> 	where appropriate.
> 	- New conditional accessors (macb_or_gem_{read,write}l) have
> 	been introduced that do the conditional accesses dependent on
> 	macb/gem type.
> 	- GEM is now dynamically detected from the module ID rather than
> 	platform device name.
> 
> Jean-Christophe, I haven't based this on your conditional clock patch as
> I wasn't sure what decision had been made on that and whether the
> at91/avr32 detection is reliable.

I'm happy to ACK this so you guys can merge this via one of the
ARM trees:

Acked-by: David S. Miller <davem@davemloft.net>
