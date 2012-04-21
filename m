From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 00/16] tipc: publication lists and zero node
 handling
Date: Fri, 20 Apr 2012 20:45:19 -0400 (EDT)
Message-ID: <20120420.204519.1199177754002742782.davem@davemloft.net>
References: <1334955924-907-1-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com,
	ying.xue@windriver.com
To: paul.gortmaker@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:37851 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754083Ab2DUApW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Apr 2012 20:45:22 -0400
In-Reply-To: <1334955924-907-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Gortmaker <paul.gortmaker@windriver.com>
Date: Fri, 20 Apr 2012 17:05:08 -0400

> This series of commits largely focuses on two things.  The 1st is
> to categorize the TIPC publication lists, so better control over
> the publications can be achieved.  The 2nd is largely to improve
> corner cases around the tipc address changes and how the <0.0.0>
> tipc address is interpreted.
> 
> What remains after this, is less than 10 commits originating from
> what was salvaged from the tipc-1.7 sourceforge fork, so I'm happy to
> see the end of this task so close.  I'll be looking at those shortly.
> 
> The tipc tests (tipcTS <--> tipcTC) have been used in both directions
> between a 32bit and a 64bit machine to do runtime testing, and the
> entire series has been confirmed to be compile time bisectable too.
> 
> Credit to Al for all the heavy lifting.  I've just refactored things
> a bit and made minor changes here and there.

Pulled, thanks Paul.

Please remove the inline tags from static functions, let the compiler
decide what to do.  The only spot appropriate to use inline tags these
days is helper functions defined in header files.
