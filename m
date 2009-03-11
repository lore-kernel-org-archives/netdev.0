From: Andi Kleen <andi@firstfloor.org>
Subject: Re: TCP rx window autotuning harmful at LAN context
Date: Wed, 11 Mar 2009 16:01:49 +0100
Message-ID: <20090311150149.GG11935@one.firstfloor.org>
References: <20090309200505.GA58375@bts.sk> <20090309.170927.130334650.davem@davemloft.net> <87bps8fkaw.fsf@basil.nowhere.org> <20090311.063058.236235660.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: andi@firstfloor.org, md@bts.sk, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:58556 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750766AbZCKOmZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Mar 2009 10:42:25 -0400
Content-Disposition: inline
In-Reply-To: <20090311.063058.236235660.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 11, 2009 at 06:30:58AM -0700, David Miller wrote:
> From: Andi Kleen <andi@firstfloor.org>
> Date: Wed, 11 Mar 2009 11:03:35 +0100
> 
> > Perhaps this points to the default buffer sizing heuristics to 
> > be too aggressive for >= 1GB?
> 
> It's necessary Andi, you can't fill a connection on a trans-
> continental connection without at least a 4MB receive buffer.

Seems pretty arbitary to me. It's the value for a given bandwidth*latency
product, but why not half or twice the bandwidth? I don't think
that number is written in stone like you claim.

Anyways it was just a test patch and it indeeds seems to address
the problem at least partly.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.
