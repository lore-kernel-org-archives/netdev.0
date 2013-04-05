From: Jonathan Woithe <jwoithe@atrad.com.au>
Subject: Re: r8169 regression: UDP packets dropped intermittantly
Date: Fri, 5 Apr 2013 10:45:26 +1030
Message-ID: <20130405001526.GC19253@marvin.atrad.com.au>
References: <20130309064647.GC4984@marvin.atrad.com.au>
 <20130311000216.GA31808@zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Jonathan Woithe <jwoithe@atrad.com.au>
To: Francois Romieu <romieu@zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from server.atrad.com.au ([150.101.241.2]:60751 "EHLO
	server.atrad.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1765429Ab3DEAPg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Apr 2013 20:15:36 -0400
Content-Disposition: inline
In-Reply-To: <20130311000216.GA31808@zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 11, 2013 at 01:02:16AM +0100, Francois Romieu wrote:
> Jonathan Woithe <jwoithe@atrad.com.au> :
> [...]
> > While we can rely on the retry system to paper over this regression, the
> > behaviour of earlier kernels suggests that there is a real issue at play. 
> > Is there any chance that this can be looked at ?
> 
> Yes.
> 
> You'll have to be a bit patient since I still have to spend a pair of non
> worked hours on a compromised system. :o/

Do you have any indication yet as to when this might be able to be looked
at?

> Take it for what it's worth but I don't test much with PREEMPT, NOHZ or
> SLUB and I never tried all those at the same time.

FYI I sent a followup to this where I determined that the regression is
still present without the above kernel configuration parameters enabled.

jonathan
