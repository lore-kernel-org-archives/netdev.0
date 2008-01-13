From: Benjamin LaHaise <bcrl@kvack.org>
Subject: Re: [PATCH] fib_semantics: prevent long hash chains in access server config
Date: Sun, 13 Jan 2008 12:58:49 -0500
Message-ID: <20080113175849.GC12775@kvack.org>
References: <20080112185819.GA12775@kvack.org> <20080112.213857.68003780.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kanga.kvack.org ([66.96.29.28]:47931 "EHLO kanga.kvack.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752585AbYAMR66 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 13 Jan 2008 12:58:58 -0500
Content-Disposition: inline
In-Reply-To: <20080112.213857.68003780.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jan 12, 2008 at 09:38:57PM -0800, David Miller wrote:
> And guess why we don't do this?  Because it's not part of
> the key.  Other aspects of the base fib_info and nexthops
> provide the uniqueness, not the devindex of the first hop.
> 
> So you'll need to find another way to do this.

Ah, you're right indeed.  It's probably easier for me to change how the 
daemon adds the local ip address for these point to point interfaces.

		-ben
-- 
"Time is of no importance, Mr. President, only life is important."
Don't Email: <zyntrop@kvack.org>.
