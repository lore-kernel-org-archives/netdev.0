From: Simon Horman <horms@verge.net.au>
Subject: Re: [v3 RFC PATCH 0/4] Implement multiqueue virtio-net
Date: Thu, 24 Feb 2011 07:59:25 +0900
Message-ID: <20110223225925.GL7361@verge.net.au>
References: <20101020085452.15579.76002.sendpatchset@krkumar2.in.ibm.com>
 <20110222074709.GA18880@verge.net.au>
 <OFAAA32513.A5D0FB9F-ON65257840.001ACE50-65257840.001D5B76@in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: anthony@codemonkey.ws, arnd@arndb.de, avi@redhat.com,
	davem@davemloft.net, eric.dumazet@gmail.com, kvm@vger.kernel.org,
	mst@redhat.com, netdev@vger.kernel.org, rusty@rustcorp.com.au
To: Krishna Kumar2 <krkumar2@in.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:51445 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754221Ab1BWW7c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Feb 2011 17:59:32 -0500
Content-Disposition: inline
In-Reply-To: <OFAAA32513.A5D0FB9F-ON65257840.001ACE50-65257840.001D5B76@in.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 23, 2011 at 10:52:09AM +0530, Krishna Kumar2 wrote:
> Simon Horman <horms@verge.net.au> wrote on 02/22/2011 01:17:09 PM:
> 
> Hi Simon,
> 
> 
> > I have a few questions about the results below:
> >
> > 1. Are the (%) comparisons between non-mq and mq virtio?
> 
> Yes - mainline kernel with transmit-only MQ patch.
> 
> > 2. Was UDP or TCP used?
> 
> TCP. I had done some initial testing on UDP, but don't have
> the results now as it is really old. But I will be running
> it again.
> 
> > 3. What was the transmit size (-m option to netperf)?
> 
> I didn't use the -m option, so it defaults to 16K. The
> script does:
> 
> netperf -t TCP_STREAM -c -C -l 60 -H $SERVER
> 
> > Also, I'm interested to know what the status of these patches is.
> > Are you planing a fresh series?
> 
> Yes. Michael Tsirkin had wanted to see how the MQ RX patch
> would look like, so I was in the process of getting the two
> working together. The patch is ready and is being tested.
> Should I send a RFC patch at this time?
> 
> The TX-only patch helped the guest TX path but didn't help
> host->guest much (as tested using TCP_MAERTS from the guest).
> But with the TX+RX patch, both directions are getting
> improvements. Remote testing is still to be done.

Hi Krishna,

thanks for clarifying the test results.
I'm looking forward to the forthcoming RFC patches.
