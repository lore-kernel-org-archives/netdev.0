From: Petko Manolov <petkan@nucleusys.com>
Subject: Re: [PATCH net 2/4] rtl8150: Use heap buffers for all register access
Date: Tue, 7 Feb 2017 16:52:44 +0200
Message-ID: <20170207145244.ff5uffxb66wyezqz@p310>
References: <20170204165451.GU3442@decadent.org.uk>
 <20170204165631.GW3442@decadent.org.uk>
 <063D6719AE5E284EB5DD2968C1650D6DB027CA6E@AcuExch.aculab.com>
 <20170206162520.GA3442@decadent.org.uk>
 <20170207103452.zb4frzltpdjaaf2s@p310>
 <20170207105131.GA2700@kroah.com>
 <20170207125324.3mtjthle4pz6344v@p310>
 <20170207130102.GA24330@kroah.com>
 <20170207132052.lp3o7nm2qtrrv4w5@p310>
 <063D6719AE5E284EB5DD2968C1650D6DB027DD9F@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Greg KH <greg@kroah.com>, Ben Hutchings <ben@decadent.org.uk>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lan.nucleusys.com ([92.247.61.126]:37332 "EHLO
        zztop.nucleusys.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1754450AbdBGOxB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 7 Feb 2017 09:53:01 -0500
Content-Disposition: inline
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6DB027DD9F@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-02-07 14:14:30, David Laight wrote:
> From: Petko Manolov
> > Sent: 07 February 2017 13:21
> ...
> > > > Would you consider what David proposed (usb_control_msg_with_malloc()) for 4.11,
> > > > for example?  I for one will use something like that in all my drivers.
> > >
> > > Sure, but you might want to make it a bit smaller of a function name :)
> > 
> > Whatever i say may be taken as volunteering. :D
> > 
> > Second - i've got really bad taste when naming things.  asdfgl() is a short name
> > although not very descriptive. ;)
> ...
> 
> Actually, for short control transfers a field in the urb itself could be used 
> (unless another 8 bytes makes the structure larger).
> 
> IIRC for xhci, the 8 byte pointer field can be marked as containing the actual 
> data - saving the hardware from doing another dma as well.

Unless set up for automatic triggering, 8 byte DMA transfer is an overkill (by 
means of having to program a bunch of IO registers), especially on a 64bit 
machine.

However, not knowing the USB host controllers specifics i'll shut up.


cheers,
Petko
