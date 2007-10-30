From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] nf_nat_h323.c unneeded rcu_dereference() calls
Date: Tue, 30 Oct 2007 15:06:20 +0100
Message-ID: <47273A5C.7040909@trash.net>
References: <20071029210618.GA4200@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	rusty@au1.ibm.com, zhaojingmin@users.sourceforge.net,
	davem@davemloft.net
To: paulmck@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:61807 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753067AbXJ3OIx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Oct 2007 10:08:53 -0400
In-Reply-To: <20071029210618.GA4200@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Paul E. McKenney wrote:
> Hello!
> 
> While reviewing rcu_dereference() uses, I came across a number of cases
> where I couldn't see how the rcu_dereference() helped.  One class of
> cases is where the variable is never subsequently dereferenced, so that
> patches like the following one would be appropriate.
> 
> So, what am I missing here?


Nothing, it was mainly intended as documentation that the hooks are
protected by RCU. I agree that its probably more confusing this way
since we're not even in a rcu_read_lock protected section.

I've queued a patch to remove them all.
