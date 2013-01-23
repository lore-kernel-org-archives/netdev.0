From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [RFC PATCH v2 10/10] ixgbe: Add support for set_channels
 ethtool operation
Date: Wed, 23 Jan 2013 21:20:45 +0000
Message-ID: <1358976045.2658.18.camel@bwh-desktop.uk.solarflarecom.com>
References: <20130110184115.29578.85768.stgit@ahduyck-cp1.jf.intel.com>
	 <20130110185846.29578.94872.stgit@ahduyck-cp1.jf.intel.com>
	 <1358353157.2923.18.camel@bwh-desktop.uk.solarflarecom.com>
	 <1358353807.29335.1.camel@ppwaskie-mobl2>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "Duyck, Alexander H" <alexander.h.duyck@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"therbert@google.com" <therbert@google.com>,
	"ycai@google.com" <ycai@google.com>,
	"eric.dumazet@gmail.com" <eric.dumazet@gmail.com>,
	"davem@davemloft.net" <davem@davemloft.net>
To: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:41598 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750899Ab3AWVUt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jan 2013 16:20:49 -0500
In-Reply-To: <1358353807.29335.1.camel@ppwaskie-mobl2>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-01-16 at 16:30 +0000, Waskiewicz Jr, Peter P wrote:
> On Wed, 2013-01-16 at 16:19 +0000, Ben Hutchings wrote:
> > On Thu, 2013-01-10 at 10:58 -0800, Alexander Duyck wrote:
> > > This change adds support for the ethtool set_channels operation.
> > > 
> > > Since the ixgbe driver has to support DCB as well as the other modes the
> > > assumption I made here is that the number of channels in DCB modes refers
> > > to the number of queues per traffic class, not the number of queues total.
> > > 
> > > Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> > 
> > In DCB mode are there separate IRQs for the different classes?
> 
> Yes.  The Rx packet buffer is split into multiple packet buffers, one
> for each online class.  After that, it's just queues assigned to the
> packet buffers, and interrupts assigned however you want them to be.

Right, I think we've been through this before.  And I can see how it
would be more useful for users to specify number of RX queues per
priority level.  But that's not what was specified...

I'm afraid the 'channels' ethtool operations have turned into a mess...
I can't see how to get to a reasonable generic definition of what they
should do.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
