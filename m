From: Chris Wright <chrisw@sous-sol.org>
Subject: Re: GSO checksum warning debug info
Date: Wed, 4 Feb 2009 08:11:55 -0800
Message-ID: <20090204161155.GG5220@sequoia.sous-sol.org>
References: <20090204002345.GF5220@sequoia.sous-sol.org> <20090204124011.GA22288@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Chris Wright <chrisw@sous-sol.org>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sous-sol.org ([216.99.217.87]:52925 "EHLO sequoia.sous-sol.org"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753194AbZBDQMa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Feb 2009 11:12:30 -0500
Content-Disposition: inline
In-Reply-To: <20090204124011.GA22288@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Herbert Xu (herbert@gondor.apana.org.au) wrote:
> On Tue, Feb 03, 2009 at 04:23:45PM -0800, Chris Wright wrote:
> > I'm able to trigger the GSO checksum warning, and after 67fd1a73 "net: Add
> > debug info to track down GSO checksum bug" here's the more verbose output:
> > 
> > e1000e: caps=(0x1119a9, 0x0) len=2960 data_len=0 ip_summed=0
> > 
> > What info would be helpful for you (couple full backtraces below)?
> 
> Interesting.  Is this a Linux guest or a Window guest?

Windows guest.

> If it's a Linux guest, it means that somewhere along the line
> the partial checksum got lost.  But I can't see anything obvious.
> Since you can reproduce this, could you add some printks along
> the path shown in the back trace to see where ip_summed gets
> zapped? So that would be tun and bridge basically.

Sure.

thanks,
-chris
