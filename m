From: Paul Mackerras <paulus@samba.org>
Subject: Re: question about softirqs
Date: Wed, 13 May 2009 15:15:34 +1000
Message-ID: <18954.22390.754419.803434@cargo.ozlabs.ibm.com>
References: <20090512081237.GA16403@elte.hu>
	<1242119578.11251.321.camel@twins>
	<20090512092348.GA29796@elte.hu>
	<20090512.214427.193728136.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mingo@elte.hu, a.p.zijlstra@chello.nl, cfriesen@nortel.com,
	tglx@linutronix.de, rostedt@goodmis.org, linuxppc-dev@ozlabs.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bilbo.ozlabs.org ([203.10.76.25]:59030 "EHLO bilbo.ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750843AbZEMFPj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 May 2009 01:15:39 -0400
In-Reply-To: <20090512.214427.193728136.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller writes:

> I fully expected us to be, at this point, talking about putting the
> pending softirq check back into the trap return path :-/

Would that actually do any good, in the case where the system has
decided that ksoftirqd is handling soft irqs at the moment?

Paul.
