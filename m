From: Willy Tarreau <w@1wt.eu>
Subject: Re: [PATCH 3/5] net: mvneta: do not schedule in mvneta_tx_timeout
Date: Sun, 12 Jan 2014 17:55:48 +0100
Message-ID: <20140112165548.GC16576@1wt.eu>
References: <1389519069-1619-1-git-send-email-w@1wt.eu> <1389519069-1619-4-git-send-email-w@1wt.eu> <1389545391.3720.56.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Gregory CLEMENT <gregory.clement@free-electrons.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:55257 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751118AbaALQz4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 12 Jan 2014 11:55:56 -0500
Content-Disposition: inline
In-Reply-To: <1389545391.3720.56.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Ben,

On Sun, Jan 12, 2014 at 04:49:51PM +0000, Ben Hutchings wrote:
(...)
> > So for now, let's simply ignore these timeouts generally caused by bugs
> > only.
> 
> No, don't ignore them.  Schedule a work item to reset the device.  (And
> remember to cancel it when stopping the device.)

OK I can try to do that. Could you recommend me one driver which does this
successfully so that I can see exactly what needs to be taken care of ?

Thanks,
Willy
