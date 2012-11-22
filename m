From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH 080/493] fddi: remove use of __devexit_p
Date: Wed, 21 Nov 2012 16:23:37 -0800
Message-ID: <20121122002337.GA16151@kroah.com>
References: <1353349642-3677-1-git-send-email-wfp5p@virginia.edu>
 <1353349642-3677-80-git-send-email-wfp5p@virginia.edu>
 <alpine.LFD.2.02.1211191842180.25230@eddie.linux-mips.org>
 <alpine.LFD.2.02.1211191912040.25230@eddie.linux-mips.org>
 <20121119192949.GA16976@kroah.com>
 <alpine.LFD.2.02.1211212334080.25230@eddie.linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Bill Pemberton <wfp5p@virginia.edu>, netdev@vger.kernel.org
To: "Maciej W. Rozycki" <macro@linux-mips.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f46.google.com ([209.85.210.46]:37523 "EHLO
	mail-da0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965062Ab2KVTXm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Nov 2012 14:23:42 -0500
Received: by mail-da0-f46.google.com with SMTP id p5so2312343dak.19
        for <netdev@vger.kernel.org>; Thu, 22 Nov 2012 11:23:41 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.02.1211212334080.25230@eddie.linux-mips.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 21, 2012 at 11:49:50PM +0000, Maciej W. Rozycki wrote:
> Greg,
> 
> > >  I have unconfused myself now, so please replace the above with the 
> > > following question: what about configurations (e.g. buses) that not 
> > > support hotplug at all?  For example apart from PCI the defxx driver 
> > > concerned here supports the TURBOchannel bus that by design does not have 
> > > the concept of live option card removal (no such circuitry).  So should 
> > > now the precious memory be wasted on systems that will never ever handle 
> > > hotplug?
> > 
> > CONFIG_HOTPLUG is always enabled now, so that's not an option anymore.
> > And again, a user can "hot unbind" a driver from a device from
> > userspace, no matter if the bus physically supports it or not.
> 
>  Hmm, what purpose does this serve for devices that cannot be physically 
> removed?  If there is none, shouldn't that policy be set by individual 
> drivers or platform even?  Even if HOTPLUG as a whole is unconditional (I 
> suppose the amount of space core support itself takes is much less to what 
> driver code can).
> 
>  TURBOchannel, although valid, is an old exotic case that might not be 
> worth arguing for, except for purity maybe.  But there are surely many 
> contemporary systems out there that are known they are never going to 
> support hot device replacement.  Consider most of the embedded systems for 
> example, where devices may even physically be cast into a single SOC (with 
> no prospect of chipping off any pieces ever ;) ), that certainly could not 
> care less of device replacement, but they do care a lot about memory 
> consumption.

Even those don't care about less than 5k of memory, do they?

>  Was this implication considered, discussed and diregarded as not 
> important enough compared to benefits from hardcoding HOTPLUG support?  

Yes, I don't know of any modern system that does not enable
CONFIG_HOTPLUG, do you?

> I'm seriously asking for a pointer, not trying to cause any stir-up -- 
> regrettably I fail to follow most discussions these days, but I would like 
> to know what the background behind this decision was.  Thanks a lot!

See Russell's response in this thread for details if you are curious.

thanks,

greg k-h
