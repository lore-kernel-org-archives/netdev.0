From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Subject: Re: Channel bonding with e1000
Date: Mon, 8 Sep 2008 11:37:47 -0700 (Pacific Daylight Time)
Message-ID: <alpine.WNT.1.10.0809081133290.7512@jbrandeb-MOBL1.amr.corp.intel.com>
References: <48C0EF8A.9070103@aei.mpg.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: Carsten Aulbert <carsten.aulbert@aei.mpg.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:46467 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750973AbYIHShx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Sep 2008 14:37:53 -0400
In-Reply-To: <48C0EF8A.9070103@aei.mpg.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 5 Sep 2008, Carsten Aulbert wrote:
> I have a brief problem and would ask for a little assistance:
> 
> On a few data servers we intend to do channel bonding. The boxes have
> two NICs on the motherboard and two extra ones on an expansion card:
> 
> 04:00.0 Ethernet controller: Intel Corporation 631xESB/632xESB DPT LAN
> Controller Copper (rev 01)
> 04:00.1 Ethernet controller: Intel Corporation 631xESB/632xESB DPT LAN
> Controller Copper (rev 01)

To help you with your consideration: this chip is embedded in the ESB2 
southbridge, and is connected (technically) over PCIe.

> 05:02.0 Ethernet controller: Intel Corporation 82546GB Gigabit Ethernet
> Controller (rev 03)
> 05:02.1 Ethernet controller: Intel Corporation 82546GB Gigabit Ethernet
> Controller (rev 03)

This chip is connected over PCI-X and should be significantly slower 
and/or higher CPU utilization than the ESB2 based chip.

Both have 64kB of internal FIFO per port, split between tx and rx.

> My simple question would be: Does it matter which two ports I can use to
> channel together when using in a set-up with MTU=9000?

It shouldn't matter, but I would take into consideration that the ESB2 
ports should be faster.

Jesse

PS in the future questions like this could be cc:'d to 
e1000-devel@lists.sourceforge.net where all the Intel wired developers 
hang out (in addition to netdev)
