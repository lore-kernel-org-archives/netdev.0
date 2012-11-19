From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH 080/493] fddi: remove use of __devexit_p
Date: Mon, 19 Nov 2012 11:29:49 -0800
Message-ID: <20121119192949.GA16976@kroah.com>
References: <1353349642-3677-1-git-send-email-wfp5p@virginia.edu>
 <1353349642-3677-80-git-send-email-wfp5p@virginia.edu>
 <alpine.LFD.2.02.1211191842180.25230@eddie.linux-mips.org>
 <alpine.LFD.2.02.1211191912040.25230@eddie.linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Bill Pemberton <wfp5p@virginia.edu>, netdev@vger.kernel.org
To: "Maciej W. Rozycki" <macro@linux-mips.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:33723 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754438Ab2KST3w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Nov 2012 14:29:52 -0500
Received: by mail-pa0-f46.google.com with SMTP id bh2so667315pad.19
        for <netdev@vger.kernel.org>; Mon, 19 Nov 2012 11:29:52 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.02.1211191912040.25230@eddie.linux-mips.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 19, 2012 at 07:16:44PM +0000, Maciej W. Rozycki wrote:
> On Mon, 19 Nov 2012, Maciej W. Rozycki wrote:
> 
> > > CONFIG_HOTPLUG is going away as an option so __devexit_p is no longer
> > > needed.
> > 
> >  Shouldn't this be switching to __exit_p() instead?  Likewise all the 
> > other changes concerned (i.e. s/__dev\(init\|exit\)/__\1/), for the sake 
> > of drivers built into the kernel proper (yes, there are people out there 
> > still doing that).  Am I missing something?
> > 
> >  This change scores my NAK as it stands, until updated accordingly or 
> > further justified.
> 
>  I have unconfused myself now, so please replace the above with the 
> following question: what about configurations (e.g. buses) that not 
> support hotplug at all?  For example apart from PCI the defxx driver 
> concerned here supports the TURBOchannel bus that by design does not have 
> the concept of live option card removal (no such circuitry).  So should 
> now the precious memory be wasted on systems that will never ever handle 
> hotplug?

CONFIG_HOTPLUG is always enabled now, so that's not an option anymore.
And again, a user can "hot unbind" a driver from a device from
userspace, no matter if the bus physically supports it or not.

thanks,

greg k-h
