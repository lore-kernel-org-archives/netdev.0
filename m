From: "Maciej W. Rozycki" <macro@linux-mips.org>
Subject: Re: [PATCH 080/493] fddi: remove use of __devexit_p
Date: Mon, 26 Nov 2012 04:35:27 +0000 (GMT)
Message-ID: <alpine.LFD.2.02.1211260425240.25230@eddie.linux-mips.org>
References: <1353349642-3677-1-git-send-email-wfp5p@virginia.edu> <1353349642-3677-80-git-send-email-wfp5p@virginia.edu> <alpine.LFD.2.02.1211191842180.25230@eddie.linux-mips.org> <alpine.LFD.2.02.1211191912040.25230@eddie.linux-mips.org> <20121119192949.GA16976@kroah.com>
 <alpine.LFD.2.02.1211212334080.25230@eddie.linux-mips.org> <20121122002337.GA16151@kroah.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Bill Pemberton <wfp5p@virginia.edu>, netdev@vger.kernel.org
To: Greg KH <gregkh@linuxfoundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from arrakis.dune.hu ([78.24.191.176]:44644 "EHLO
	eddie.linux-mips.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753951Ab2KZEfa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Nov 2012 23:35:30 -0500
Received: from localhost.localdomain ([127.0.0.1]:54970 "EHLO
        localhost.localdomain" rhost-flags-OK-OK-OK-OK)
        by eddie.linux-mips.org with ESMTP id S6816743Ab2KZEf1uKpjF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 26 Nov 2012 05:35:27 +0100
In-Reply-To: <20121122002337.GA16151@kroah.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 21 Nov 2012, Greg KH wrote:

> >  TURBOchannel, although valid, is an old exotic case that might not be 
> > worth arguing for, except for purity maybe.  But there are surely many 
> > contemporary systems out there that are known they are never going to 
> > support hot device replacement.  Consider most of the embedded systems for 
> > example, where devices may even physically be cast into a single SOC (with 
> > no prospect of chipping off any pieces ever ;) ), that certainly could not 
> > care less of device replacement, but they do care a lot about memory 
> > consumption.
> 
> Even those don't care about less than 5k of memory, do they?

 I guess you're right.  As long as it's not 5k per driver + 
who_knows_how_much per platform for some generic stuff that is.  Of course 
this is still a waste, but I can accept it as a compromise between the use 
of machine resources and the cost of maintenance.

> >  Was this implication considered, discussed and diregarded as not 
> > important enough compared to benefits from hardcoding HOTPLUG support?  
> 
> Yes, I don't know of any modern system that does not enable
> CONFIG_HOTPLUG, do you?

 I've never enabled it outside x86 to be honest.  None of the platforms I 
care of supports it in hardware.

> > I'm seriously asking for a pointer, not trying to cause any stir-up -- 
> > regrettably I fail to follow most discussions these days, but I would like 
> > to know what the background behind this decision was.  Thanks a lot!
> 
> See Russell's response in this thread for details if you are curious.

 Hmm, not in my inbox for some reason (unless I'm blind), but thanks for 
the pointer, I'll see if I can chase it online in some mailing list 
archive.

  Maciej
