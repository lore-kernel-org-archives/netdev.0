From: Andi Kleen <ak@suse.de>
Subject: Re: reminder, 2.6.18 window...
Date: Fri, 26 May 2006 11:43:05 +0200
Message-ID: <200605261143.06131.ak@suse.de>
References: <20060523.182217.59656237.davem@davemloft.net> <447412CA.50303@ipom.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns1.suse.de ([195.135.220.2]:31199 "EHLO mx1.suse.de")
	by vger.kernel.org with ESMTP id S1750703AbWEZJsB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 May 2006 05:48:01 -0400
To: Phil Dibowitz <phil@ipom.com>
In-Reply-To: <447412CA.50303@ipom.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 24 May 2006 10:01, Phil Dibowitz wrote:
> David Miller wrote:
> > Some time in the next few weeks, it is likely that the 2.6.18
> > merge window will open up shortly after a 2.6.17 release.
> > 
> > So if you have major 2.6.18 submissions planned for the networking,
> > you need to start thinking about getting it to me now.
> > 
> > There is a 2.6.18 tree up at:
> > 
> > master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.18.git
> > 
> > All it has right now is the I/O AT stuff at the moment, and I plan to
> > put Stephen Hemminger's LLC multicast/datagram changes in there as
> > well.
> 
> David,
> 
> I posted a patch for adding support for network device statistic
> resetting via ethtool. I saw no objections to it...

I think it's a bad idea because it's inherently racey

(I think I objected originally too) 

Similar patches were rejected a couple of times over the years already.

> I'd like to get this into 2.6.18. It's self-contained, so it has little
> chance of breaking other things and adds a useful feature that I've seen
> a lot of requests for.

It's broken by design.
-Andi

 
