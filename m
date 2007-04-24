From: Greg KH <greg@kroah.com>
Subject: Re: [PATCH] usb-net/pegasus: fix pegasus carrier detection
Date: Tue, 24 Apr 2007 10:04:29 -0700
Message-ID: <20070424170429.GA13668@kroah.com>
References: <1177424406.13684.5.camel@localhost.localdomain> <462E3508.1030703@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dan Williams <dcbw@redhat.com>,
	Petko Manolov <petkan@nucleusys.com>, netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:38230 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754266AbXDXRHH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Apr 2007 13:07:07 -0400
Content-Disposition: inline
In-Reply-To: <462E3508.1030703@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Apr 24, 2007 at 12:49:12PM -0400, Jeff Garzik wrote:
>  Long term, Greg seemed OK with moving the net drivers from drivers/usb/net 
>  to drivers/usb/net, in line with the current policy of placing net drivers 
>  in drivers/net/*, bus agnostic.  After that move, sending to netdev and me 
>  (as you did here) would be the preferred avenue.

Speaking of which, do you want me to do this in the 2.6.22-rc1
timeframe?  Usually big code moves like this are good to do right after
rc1 comes out as the major churn is usually completed then.

thanks,

greg k-h
