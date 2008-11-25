From: Jesper Dangaard Brouer <hawk@diku.dk>
Subject: Re: [PATCH] Naming interrupt vectors/niu
Date: Tue, 25 Nov 2008 16:58:06 +0100 (CET)
Message-ID: <Pine.LNX.4.64.0811251652240.27162@tyr.diku.dk>
References: <18732.7560.67492.918339@robur.slu.se>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Robert.Olsson@data.slu.se
To: Robert Olsson <robert@robur.slu.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgw2.diku.dk ([130.225.96.92]:45825 "EHLO mgw2.diku.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751528AbYKYP6J (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Nov 2008 10:58:09 -0500
In-Reply-To: <18732.7560.67492.918339@robur.slu.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Tue, 25 Nov 2008, Robert Olsson wrote:

> A patch to put names on the niu interrupt vectors according the syntax below.
> This is needed to assign correct affinity.
>
> > So on a multiqueue card with 2 RX queues and 2 TX queues we'd
> > have names like:
> >
> > 	eth0-rx-0
> > 	eth0-rx-1
> > 	eth0-tx-0
> > 	eth0-tx-1
>
>
> Signed-off-by: Robert Olsson <robert.olsson@its.uu.se>

Tested-by: Jesper Dangaard Brouer <jdb@comx.dk>


I have tested the patch and it also works on the Quad 1G SUN NIC.
I really like the idea behind the patch, as it makes it a lot easier to 
get the smp affinity right...

Hilsen
   Jesper Brouer

--
-------------------------------------------------------------------
MSc. Master of Computer Science
Dept. of Computer Science, University of Copenhagen
Author of http://www.adsl-optimizer.dk
-------------------------------------------------------------------
