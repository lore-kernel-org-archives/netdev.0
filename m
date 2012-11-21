From: "Maciej W. Rozycki" <macro@linux-mips.org>
Subject: Re: [PATCH 080/493] fddi: remove use of __devexit_p
Date: Wed, 21 Nov 2012 23:49:50 +0000 (GMT)
Message-ID: <alpine.LFD.2.02.1211212334080.25230@eddie.linux-mips.org>
References: <1353349642-3677-1-git-send-email-wfp5p@virginia.edu> <1353349642-3677-80-git-send-email-wfp5p@virginia.edu> <alpine.LFD.2.02.1211191842180.25230@eddie.linux-mips.org> <alpine.LFD.2.02.1211191912040.25230@eddie.linux-mips.org>
 <20121119192949.GA16976@kroah.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Bill Pemberton <wfp5p@virginia.edu>, netdev@vger.kernel.org
To: Greg KH <gregkh@linuxfoundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from arrakis.dune.hu ([78.24.191.176]:37307 "EHLO
	eddie.linux-mips.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754093Ab2KVTAZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Nov 2012 14:00:25 -0500
Received: from localhost.localdomain ([127.0.0.1]:44805 "EHLO
        localhost.localdomain" rhost-flags-OK-OK-OK-OK)
        by eddie.linux-mips.org with ESMTP id S6828054Ab2KUXturht0N (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 22 Nov 2012 00:49:50 +0100
In-Reply-To: <20121119192949.GA16976@kroah.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Greg,

> >  I have unconfused myself now, so please replace the above with the 
> > following question: what about configurations (e.g. buses) that not 
> > support hotplug at all?  For example apart from PCI the defxx driver 
> > concerned here supports the TURBOchannel bus that by design does not have 
> > the concept of live option card removal (no such circuitry).  So should 
> > now the precious memory be wasted on systems that will never ever handle 
> > hotplug?
> 
> CONFIG_HOTPLUG is always enabled now, so that's not an option anymore.
> And again, a user can "hot unbind" a driver from a device from
> userspace, no matter if the bus physically supports it or not.

 Hmm, what purpose does this serve for devices that cannot be physically 
removed?  If there is none, shouldn't that policy be set by individual 
drivers or platform even?  Even if HOTPLUG as a whole is unconditional (I 
suppose the amount of space core support itself takes is much less to what 
driver code can).

 TURBOchannel, although valid, is an old exotic case that might not be 
worth arguing for, except for purity maybe.  But there are surely many 
contemporary systems out there that are known they are never going to 
support hot device replacement.  Consider most of the embedded systems for 
example, where devices may even physically be cast into a single SOC (with 
no prospect of chipping off any pieces ever ;) ), that certainly could not 
care less of device replacement, but they do care a lot about memory 
consumption.

 Was this implication considered, discussed and diregarded as not 
important enough compared to benefits from hardcoding HOTPLUG support?  
I'm seriously asking for a pointer, not trying to cause any stir-up -- 
regrettably I fail to follow most discussions these days, but I would like 
to know what the background behind this decision was.  Thanks a lot!

  Maciej
