From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: AIM9 regression
Date: Wed, 24 Sep 2008 14:34:19 -0700
Message-ID: <20080924143419.467e0e76@extreme>
References: <20080923.221831.126801015.davem@davemloft.net>
	<20080924081603.08a5f808@extreme>
	<48DA90BE.5090208@linux-foundation.org>
	<20080924.125346.178957726.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: cl@linux-foundation.org, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:45858 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751748AbYIXVeW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Sep 2008 17:34:22 -0400
In-Reply-To: <20080924.125346.178957726.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 24 Sep 2008 12:53:46 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: Christoph Lameter <cl@linux-foundation.org>
> Date: Wed, 24 Sep 2008 14:10:54 -0500
> 
> > Stephen Hemminger wrote:
> > 
> > > These loopback benchmarks are often more sensitive to scheduler than networking
> > > changes.
> > 
> > Just ran a test with real NICs which show the same issues. I guess I need to
> > get familiar with the network stack and start hacking on it. Sigh.
> 
> I feel your pain, I think people are being very unreasonable in their
> analysis of your numbers, and for this I want to personally apologize.
> 
> It's clearly a networking issue in my eyes, and I wish my co-developers
> in networking would treat it as such instead of pushing the blame under
> the carpet and saying "scheduler", "SLUB", and all kinds of other bullshit
> without any facts on this specific case to back up such accusations.

Is this a one time change, or has networking been getting slower over time?
