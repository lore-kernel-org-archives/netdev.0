From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 07/28] mm: emergency pool
Date: Sat, 23 Feb 2008 00:05:54 -0800
Message-ID: <20080223000554.04c4f755.akpm@linux-foundation.org>
References: <20080220144610.548202000@chello.nl>
	<20080220150306.165236000@chello.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	netdev@vger.kernel.org, trond.myklebust@fys.uio.no
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([207.189.120.13]:35128 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933044AbYBWIIx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Feb 2008 03:08:53 -0500
In-Reply-To: <20080220150306.165236000@chello.nl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 20 Feb 2008 15:46:17 +0100 Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:

> @@ -213,7 +213,7 @@ enum zone_type {
>  
>  struct zone {
>  	/* Fields commonly accessed by the page allocator */
> -	unsigned long		pages_min, pages_low, pages_high;
> +	unsigned long		pages_emerg, pages_min, pages_low, pages_high;

It would be nice to make these one-per-line, then document them.
