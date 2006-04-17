From: Jesse Brandeburg <jesse.brandeburg@intel.com>
Subject: Re: fixing sk_stream_rfree()
Date: Mon, 17 Apr 2006 14:56:39 -0700 (Pacific Daylight Time)
Message-ID: <Pine.WNT.4.63.0604171455460.3848@jbrandeb-desk.amr.corp.intel.com>
References: <20060417.132904.55913090.davem@davemloft.net>
 <Pine.WNT.4.63.0604171405470.3848@jbrandeb-desk.amr.corp.intel.com>
 <20060417214054.GA30730@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmr18.intel.com ([134.134.136.17]:20883 "EHLO
	orsfmr003.jf.intel.com") by vger.kernel.org with ESMTP
	id S1750909AbWDQV54 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Apr 2006 17:57:56 -0400
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20060417214054.GA30730@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Mon, 17 Apr 2006, Herbert Xu wrote:

> 
> On Mon, Apr 17, 2006 at 02:09:43PM -0700, Jesse Brandeburg wrote:
> >
> > we explicitly enabled TSO before performing the test.
> > attached bz2 due to size:
> 
> Thanks a lot.  Are those promiscuous mode messages caused by tcpdump?
> If so could you try it without doing a tcpdump or any other af_packet
> applications?

yes, the promiscuous up/down messages are from tcpdump. We were checking 
whether TSO was enabled by looking at the traffic. The interface was NOT 
in promiscuous mode while running the test.

> > Let me know if there is anything else I can do,
> 
> Since you can reproduce this at will now, please modify one of those
> warning messages to print out the actual value of sk_forward_alloc.
> It can gives a clue.  For instance if it happens to be a multiple of
> PAGE_SIZE, then we know it may be related to the reclaim stuff.

will do.
