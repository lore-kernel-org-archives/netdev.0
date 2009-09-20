From: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Subject: Re: SO_TIMESTAMPING fix and design decisions
Date: Sun, 20 Sep 2009 10:48:13 -0700
Message-ID: <1253468893.2654.6.camel@localhost.localdomain>
References: <20090919192549.0735c93a@pundit>
	 <1253398161.14869.2.camel@localhost.localdomain>
	 <20090920095242.5cd42f1a@pundit>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Christopher Zimmermann <madroach@zakweb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:2989 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755079AbZITRsG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 20 Sep 2009 13:48:06 -0400
In-Reply-To: <20090920095242.5cd42f1a@pundit>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2009-09-20 at 00:52 -0700, Christopher Zimmermann wrote:
> On Sat, 19 Sep 2009 15:09:21 -0700
> Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com> wrote:
> 
> > > hardware timestamps only work for the Intel igb driver. I have 
> > > access to two test machines with NICs supported by this driver.
> > 
> > Intel's 82599, supported by ixgbe, also has the same IEEE 1588
> > timestamping support in hardware.  We haven't implemented the support
> > yet in ixgbe, but the hardware is there and does work.  If you were
> > curious of the interface, the datasheet for the hardware is available on
> > our SourceForge site (e1000.sf.net).
> 
> hi! thanks for the reply.
> 
> I already got the documentation for the 82576 cards I have access to. I 
> won't be able to afford another pair.
> 
> What do you think about my idea to expose the relevant registers to 
> userspace? I believe it would not be too difficult for userspace to 
> configure the timestamps this way and would allow way more flexibility. 
> Of course I would #DEFINE the constants used to set the registers.

The patch seems reasonable, but I haven't played with the igb
timestamping very much.  However, what impact will this have on the
existing ptpd userspace daemon?

-PJ

