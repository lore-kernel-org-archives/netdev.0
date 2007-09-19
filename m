From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] iproute2: enable setting rto_min, rtt and rttvar in
 tc-esque units
Date: Wed, 19 Sep 2007 15:03:12 -0700 (PDT)
Message-ID: <20070919.150312.31444471.davem@davemloft.net>
References: <200709182015.NAA25590@tardy.cup.hp.com>
	<20070919145133.7aff0a5b@freepuppy.rosehill.hemminger.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rick.jones2@hp.com, netdev@vger.kernel.org
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56764
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751147AbXISWDM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Sep 2007 18:03:12 -0400
In-Reply-To: <20070919145133.7aff0a5b@freepuppy.rosehill.hemminger.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Wed, 19 Sep 2007 14:51:33 -0700

> On Tue, 18 Sep 2007 13:15:26 -0700 (PDT)
> Rick Jones <rick.jones2@hp.com> wrote:
> 
> > Enable users of ip to specify the times for rtt, rttvar and rto_min
> > in human-friendly terms a la "tc" while maintaining backwards 
> > compatability with the previous "raw" mechanism.  Builds upon
> > David Miller's uncommited patch to set rto_min.
> > 
> > Signed-off-by: Rick Jones <rick.jones2@hp.com>
> 
> Thanks, I'll put it in the 2.6.24 version of iproute2 (assuming dave
> takes the rto_min patch).

If you're talking about the kernel side, Linus's tree already
has the per-route rto_min stuff.
