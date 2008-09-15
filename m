From: Jeff Garzik <jeff@garzik.org>
Subject: Re: Bonding and Neighbour Discovery on IPv6-only devices
Date: Mon, 15 Sep 2008 14:00:15 -0400
Message-ID: <20080915180015.GB1078@havoc.gtf.org>
References: <200809151335.16817.asid@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Alex Sidorenko <asid@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from havoc.gtf.org ([69.61.125.42]:59321 "EHLO havoc.gtf.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754080AbYIOSAQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Sep 2008 14:00:16 -0400
Content-Disposition: inline
In-Reply-To: <200809151335.16817.asid@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 15, 2008 at 01:35:16PM -0400, Alex Sidorenko wrote:
> Hello,
> 
> I suspect that there are some problems while switching slaves manually on 
> IPv6-only bonds. I have tested that this does not work on 2.6.18 kernel 
> (RHEL5). I looked at recent sources (2.6.26) and even though there were 
> multiple changes in bonding code, I still don't see how this could work.
> 
> Testing setup
> -------------
> 
> Two ethernets enslaved (eth2 and eh3), active-backup bond has IPv6-only 
> address (no IPv4)
> 
> Everything works fine, but if we switch the slave doing
> 
> # ifenslave -c bond0 eth3
> 
> the incoming ping6 to this host stops for up to several minutes (waiting until 
> the switch updates its caches).

We _just_ put in an IPv6 fix, FWIW...

	Jeff



