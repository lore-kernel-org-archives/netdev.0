From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH net-next 5/5] tipc: clean out all instances of #if 0'd
 unused code
Date: Wed, 13 Oct 2010 13:23:04 -0400
Message-ID: <20101013172304.GG31379@hmsreliant.think-freely.org>
References: <1286929558-2954-1-git-send-email-paul.gortmaker@windriver.com>
 <1286929558-2954-5-git-send-email-paul.gortmaker@windriver.com>
 <20101013162652.GF31379@hmsreliant.think-freely.org>
 <4CB5E79B.4060507@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	allan.stephens@windriver.com
To: Paul Gortmaker <paul.gortmaker@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:44412 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751585Ab0JMRXK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Oct 2010 13:23:10 -0400
Content-Disposition: inline
In-Reply-To: <4CB5E79B.4060507@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 13, 2010 at 01:08:43PM -0400, Paul Gortmaker wrote:
> On 10-10-13 12:26 PM, Neil Horman wrote:
> > On Tue, Oct 12, 2010 at 08:25:58PM -0400, Paul Gortmaker wrote:
> >> Remove all instances of legacy, or as yet to be implemented code
> >> that is currently living within an #if 0 ... #endif block.
> >> In the rare instance that some of it be needed in the future,
> >> it can still be dragged out of history, but there is no need
> >> for it to sit in mainline.
> >>
> >> Signed-off-by: Paul Gortmaker<paul.gortmaker@windriver.com>
> > Acked-by: Neil Horman<nhorman@tuxdriver.com>
> > 
> 
> Thanks for all the reviews.  As I'd indicated a while back, I
> am by far no TIPC expert, so it may take me a bit to digest
> it and rework things on 1 --> 4. That will probably put them
> into the "for-38" net-next timeframe, as I'm guessing net-next
> that is destined for 2.6.37 will close in a day or two.
> 
No problem,  Most of what I identified I don't think is strictly a tipc related
issue, they're more just correct usage of various primitives (i.e. don't
initalize a work queue every time right before you schedule it), and use
list_add/list_del, instead of just munging data structures onto a list).  Most
looks pretty easy to correct I think.  Allan can probably help you out if tipc
specific knoweldge is needed.

Neil

> This cleanup patch (patch #5) doesn't explicitly depend on
> the other 4 bearer related patches, so it can be applied
> at whatever time is most convenient for Dave.
> 
> Paul.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
