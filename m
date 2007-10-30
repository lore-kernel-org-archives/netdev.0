From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH] nf_nat_h323.c unneeded rcu_dereference() calls
Date: Tue, 30 Oct 2007 08:37:04 -0700
Message-ID: <20071030153704.GB8285@linux.vnet.ibm.com>
References: <20071029210618.GA4200@linux.vnet.ibm.com> <47273A5C.7040909@trash.net>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	rusty@au1.ibm.com, zhaojingmin@users.sourceforge.net,
	davem@davemloft.net
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e31.co.us.ibm.com ([32.97.110.149]:51836 "EHLO
	e31.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754054AbXJ3PhV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Oct 2007 11:37:21 -0400
Content-Disposition: inline
In-Reply-To: <47273A5C.7040909@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 30, 2007 at 03:06:20PM +0100, Patrick McHardy wrote:
> Paul E. McKenney wrote:
> >Hello!
> >
> >While reviewing rcu_dereference() uses, I came across a number of cases
> >where I couldn't see how the rcu_dereference() helped.  One class of
> >cases is where the variable is never subsequently dereferenced, so that
> >patches like the following one would be appropriate.
> >
> >So, what am I missing here?
> 
> Nothing, it was mainly intended as documentation that the hooks are
> protected by RCU. I agree that its probably more confusing this way
> since we're not even in a rcu_read_lock protected section.
> 
> I've queued a patch to remove them all.

Thank you!!!

						Thanx, Paul
