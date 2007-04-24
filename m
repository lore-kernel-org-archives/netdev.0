From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] usb-net/pegasus: fix pegasus carrier detection
Date: Tue, 24 Apr 2007 13:41:47 -0400
Message-ID: <462E415B.3020707@garzik.org>
References: <1177424406.13684.5.camel@localhost.localdomain> <462E3508.1030703@garzik.org> <20070424170429.GA13668@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Dan Williams <dcbw@redhat.com>,
	Petko Manolov <petkan@nucleusys.com>, netdev@vger.kernel.org
To: Greg KH <greg@kroah.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:40108 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1422821AbXDXRlv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Apr 2007 13:41:51 -0400
In-Reply-To: <20070424170429.GA13668@kroah.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Greg KH wrote:
> On Tue, Apr 24, 2007 at 12:49:12PM -0400, Jeff Garzik wrote:
>>  Long term, Greg seemed OK with moving the net drivers from drivers/usb/net 
>>  to drivers/usb/net, in line with the current policy of placing net drivers 
>>  in drivers/net/*, bus agnostic.  After that move, sending to netdev and me 
>>  (as you did here) would be the preferred avenue.
> 
> Speaking of which, do you want me to do this in the 2.6.22-rc1
> timeframe?  Usually big code moves like this are good to do right after
> rc1 comes out as the major churn is usually completed then.

Whatever works best for you.  There are few if any interlocking 
dependencies.

Or I could wait for you to do your 2.6.22 merge window USB push (sans 
this move), and then I can do the rename-across-directories in git in my 
normal netdev-2.6.git stream.

	Jeff



