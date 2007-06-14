From: Bill Fink <billfink@mindspring.com>
Subject: Re: [PATCH] TCP: remove initial_ssthresh from Cubic
Date: Thu, 14 Jun 2007 00:03:41 -0400
Message-ID: <20070614000341.b9151782.billfink@mindspring.com>
References: <20070613102718.61d67a36@localhost>
	<20070613.112652.112623832.davem@davemloft.net>
	<20070613113149.5cd1b11e@localhost>
	<20070613.114621.85409138.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, sangtae.ha@gmail.com,
	rhee@eos.ncsu.edu, rhee@ncsu.edu, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-galgo.atl.sa.earthlink.net ([209.86.89.61]:47752 "EHLO
	elasmtp-galgo.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751039AbXFNEED (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Jun 2007 00:04:03 -0400
In-Reply-To: <20070613.114621.85409138.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 13 Jun 2007, David Miller wrote:

> From: Stephen Hemminger <shemminger@linux-foundation.org>
> Date: Wed, 13 Jun 2007 11:31:49 -0700
> 
> > Maybe it is time to remove BIC?
> 
> I don't see any compelling reason, the same could be said
> of the other experimental protocols we include in the tree.

I agree bic should be kept.  As I pointed out, if someone did want
to set the bic/cubic initial_ssthresh to 100 globally, my tests
showed bic's performance during the initial slow start phase was
far superior to cubic's.  I don't know if this is a bug or a
feature with cubic.

						-Bill
