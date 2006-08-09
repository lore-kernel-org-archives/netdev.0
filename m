From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH] limit rt cache size
Date: Wed, 9 Aug 2006 18:32:26 +0200
Message-ID: <200608091832.26492.ak@suse.de>
References: <200608080711.06788.ak@suse.de> <200608090302.19634.ak@suse.de> <Pine.LNX.4.61.0608090913410.2452@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, kuznet@ms2.inr.ac.ru,
	dev@sw.ru, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.suse.de ([195.135.220.2]:63686 "EHLO mx1.suse.de")
	by vger.kernel.org with ESMTP id S1750740AbWHIQcq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Aug 2006 12:32:46 -0400
To: akepner@sgi.com
In-Reply-To: <Pine.LNX.4.61.0608090913410.2452@localhost.localdomain>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> > There will be some hickup, but as long as the downtime
> > is limited it shouldn't be too bad.
> >
> 
> Benchmarks are in order....

One issue I forgot earlier and Kirill pointed out is that the
reallocation would require vmalloc because memory will be too fragmented
to get a big piece of physical memory. So it would add TLB pressure. 

Can't think of a good way around that.

You might have been right with being sceptical.

-Andi
