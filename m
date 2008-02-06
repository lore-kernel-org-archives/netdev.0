From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH] ipvs: Make wrr "no available servers" error message
	rate-limited
Date: Wed, 6 Feb 2008 11:19:09 +0900
Message-ID: <20080206021909.GA32678@verge.net.au>
References: <1202243421-2774-1-git-send-email-sven.wegener@stealer.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Sven Wegener <sven.wegener@stealer.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from koto.vergenet.net ([210.128.90.7]:58547 "EHLO koto.vergenet.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758528AbYBFCTN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Feb 2008 21:19:13 -0500
Content-Disposition: inline
In-Reply-To: <1202243421-2774-1-git-send-email-sven.wegener@stealer.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 05, 2008 at 09:30:21PM +0100, Sven Wegener wrote:
> No available servers is more an error message than something informational. It
> should also be rate-limited, else we're going to flood our logs on a busy
> director, if all real servers are out of order with a weight of zero.
> 
> Signed-off-by: Sven Wegener <sven.wegener@stealer.net>

Hi Sven,

this looks good to me.

Acked-by: Simon Horman <horms@verge.net.au>

> ---
> 
> Actually, do we need this message at all? The wrr scheduler is the only one
> printing an error message in such a case.

I was wondering about that too. Though I'd err on the side of adding
it to the other schedulers as neccessary rather than removing it here.
But if you'd rather just get rid of it, I have no strong objections.

-- 
Horms

