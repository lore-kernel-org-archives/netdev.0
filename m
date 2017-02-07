From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net 2/4] rtl8150: Use heap buffers for all register
 access
Date: Tue, 7 Feb 2017 14:14:30 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DB027DD9F@AcuExch.aculab.com>
References: <20170204165451.GU3442@decadent.org.uk>
 <20170204165631.GW3442@decadent.org.uk>
 <063D6719AE5E284EB5DD2968C1650D6DB027CA6E@AcuExch.aculab.com>
 <20170206162520.GA3442@decadent.org.uk>
 <20170207103452.zb4frzltpdjaaf2s@p310> <20170207105131.GA2700@kroah.com>
 <20170207125324.3mtjthle4pz6344v@p310> <20170207130102.GA24330@kroah.com>
 <20170207132052.lp3o7nm2qtrrv4w5@p310>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: Ben Hutchings <ben@decadent.org.uk>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>
To: 'Petko Manolov' <petkan@nucleusys.com>, Greg KH <greg@kroah.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out4.electric.net ([192.162.216.193]:59104 "EHLO
        smtp-out4.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754114AbdBGOOj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 7 Feb 2017 09:14:39 -0500
In-Reply-To: <20170207132052.lp3o7nm2qtrrv4w5@p310>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Petko Manolov
> Sent: 07 February 2017 13:21
...
> > > Would you consider what David proposed (usb_control_msg_with_malloc()) for 4.11,
> > > for example?  I for one will use something like that in all my drivers.
> >
> > Sure, but you might want to make it a bit smaller of a function name :)
> 
> Whatever i say may be taken as volunteering. :D
> 
> Second - i've got really bad taste when naming things.  asdfgl() is a short name
> although not very descriptive. ;)
...

Actually, for short control transfers a field in the urb itself could be used
(unless another 8 bytes makes the structure larger).

IIRC for xhci, the 8 byte pointer field can be marked as containing the
actual data - saving the hardware from doing another dma as well.

	David
