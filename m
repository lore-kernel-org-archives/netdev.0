From: Heiko Carstens <heiko.carstens@de.ibm.com>
Subject: Re: [patch] ipvs: force read of atomic_t in while loop
Date: Wed, 8 Aug 2007 12:28:35 +0200
Message-ID: <20070808102835.GC14530@osiris.boeblingen.de.ibm.com>
References: <20070808093300.GA14530@osiris.boeblingen.de.ibm.com> <20070808.032131.35507346.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, schwidefsky@de.ibm.com,
	wensong@linux-vs.org, horms@verge.net.au
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate5.uk.ibm.com ([195.212.29.138]:19825 "EHLO
	mtagate5.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750829AbXHHK3e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Aug 2007 06:29:34 -0400
Content-Disposition: inline
In-Reply-To: <20070808.032131.35507346.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 08, 2007 at 03:21:31AM -0700, David Miller wrote:
> From: Heiko Carstens <heiko.carstens@de.ibm.com>
> Date: Wed, 8 Aug 2007 11:33:00 +0200
> 
> > Just saw this while grepping for atomic_reads in a while loops.
> > Maybe we should re-add the volatile to atomic_t. Not sure.
> 
> I think whatever the choice, it should be done consistently
> on every architecture.
> 
> It's just asking for trouble if your arch does it differently from
> every other.

Well..currently it's i386/x86_64 and s390 which have no volatile
in atomic_t. And yes, of course I agree it should be consistent
across all architectures. But it isn't.
