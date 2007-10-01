From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [RFC] Make TCP prequeue configurable
Date: 01 Oct 2007 14:24:44 +0200
Message-ID: <p738x6n6n03.fsf@bingen.suse.de>
References: <46FC29E1.9010809@cosmosbay.com>
	<20070927154432.6ca3b525@freepuppy.rosehill>
	<46FC663A.6030601@psc.edu>
	<20070928.154031.99471318.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jheffner@psc.edu, shemminger@linux-foundation.org,
	dada1@cosmosbay.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:60348 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750977AbXJAMYr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Oct 2007 08:24:47 -0400
In-Reply-To: <20070928.154031.99471318.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller <davem@davemloft.net> writes:
> 
> Furthermore, prequeue puts the stack input processing work into user
> context, which means that the users will be charged more fairly for
> the work that is done for them.

For more details on this people might want to read the old Lazy Receiver
Processing papers: http://www.cs.rice.edu/CS/Systems/LRP/

-Andi

