From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: Re: surprising memory request
Date: Fri, 18 Jan 2013 10:11:08 -0800
Message-ID: <20130118181108.GB15466@ppwaskie-mobl2.amr.corp.intel.com>
References: <20130118085818.147220.FMU5901@air.gr8dns.org>
 <20130118180930.GA15466@ppwaskie-mobl2.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, David Woodhouse <dwmw2@infradead.org>
To: Dirk Hohndel <dirk@hohndel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:25484 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751487Ab3ARSL0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Jan 2013 13:11:26 -0500
Content-Disposition: inline
In-Reply-To: <20130118180930.GA15466@ppwaskie-mobl2.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 18, 2013 at 10:09:30AM -0800, Waskiewicz Jr, Peter P wrote:
> On Fri, Jan 18, 2013 at 08:58:18AM -0800, Dirk Hohndel wrote:
> > 
> > Running openconnect on a very recent 3.8 (a few commits before Linus cut
> > RC4) I get this allocation failure. I'm unclear why we would need 128
> > contiguous pages here...
> > 
> > /D
> 
> [...]
> 
> > [66015.674074] 541777 total pagecache pages
> > [66015.674075] 142 pages in swap cache
> > [66015.674078] Swap cache stats: add 4420, delete 4278, find 106/118
> > [66015.674080] Free swap  = 9197216kB
> > [66015.674082] Total swap = 9213948kB
> > [66015.710738] 2094576 pages RAM
> > [66015.710745] 85536 pages reserved
> > [66015.710746] 1755663 pages shared
> > [66015.710748] 1488520 pages non-shared
> > [66015.710752] netdev: Unable to allocate 1024 tx queues
> 
> What device are you using that is trying to allocate so many Tx queues?
> Assuming this is coming from the VPN device coming online; is SELinux
> in enforcing mode?  There have been a number of changes in the tun
> driver recently around the multiqueue area with SELinux, just a theory
> at this point.  I can keep digging.

Or I can see Eric's mail before replying, nevermind.
