From: Oliver Neukum <oliver@neukum.org>
Subject: Re: question on netdev_completed_queue()
Date: Fri, 09 Nov 2012 17:58:08 +0100
Message-ID: <16131769.FsMAT47cqV@linux-lqwf.site>
References: <1476426.QTHA7ibVHZ@linux-lqwf.site> <1352407453.2771.18.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out002.kontent.com ([81.88.40.216]:50981 "EHLO
	smtp-out002.kontent.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754194Ab2KIQ6E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Nov 2012 11:58:04 -0500
In-Reply-To: <1352407453.2771.18.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 08 November 2012 20:44:13 Ben Hutchings wrote:
> On Thu, 2012-11-08 at 20:38 +0100, Oliver Neukum wrote:
> > Hi,
> > 
> > is this function to be called whenever a driver is done with transmitting
> > data, whether the transmission be successful or not?
> 
> Yes, BQL tracks number of packets and bytes in each queue and you have
> to tell it about all insertions and removals from the queue.  (Except
> that if you flush the queue, you can use netdev_reset_queue() rather
> than trying to counting the remaining packets and bytes.)

Thank you. That opens up the next question. How exact does the count
have to be? Do you care about the exact amount of data or does it just
have to be internally consistent?

	Regards
		Oliver
