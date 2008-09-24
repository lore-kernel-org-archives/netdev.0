From: David Miller <davem@davemloft.net>
Subject: Re: AIM9 regression
Date: Wed, 24 Sep 2008 12:53:46 -0700 (PDT)
Message-ID: <20080924.125346.178957726.davem@davemloft.net>
References: <20080923.221831.126801015.davem@davemloft.net>
	<20080924081603.08a5f808@extreme>
	<48DA90BE.5090208@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org
To: cl@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54521
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753159AbYIXTx6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Sep 2008 15:53:58 -0400
In-Reply-To: <48DA90BE.5090208@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Christoph Lameter <cl@linux-foundation.org>
Date: Wed, 24 Sep 2008 14:10:54 -0500

> Stephen Hemminger wrote:
> 
> > These loopback benchmarks are often more sensitive to scheduler than networking
> > changes.
> 
> Just ran a test with real NICs which show the same issues. I guess I need to
> get familiar with the network stack and start hacking on it. Sigh.

I feel your pain, I think people are being very unreasonable in their
analysis of your numbers, and for this I want to personally apologize.

It's clearly a networking issue in my eyes, and I wish my co-developers
in networking would treat it as such instead of pushing the blame under
the carpet and saying "scheduler", "SLUB", and all kinds of other bullshit
without any facts on this specific case to back up such accusations.
