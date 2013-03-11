From: Jonathan Woithe <jwoithe@atrad.com.au>
Subject: Re: r8169 regression: UDP packets dropped intermittantly
Date: Mon, 11 Mar 2013 10:47:29 +1030
Message-ID: <20130311001729.GA8606@marvin.atrad.com.au>
References: <20130309064647.GC4984@marvin.atrad.com.au>
 <20130311000216.GA31808@zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Jonathan Woithe <jwoithe@atrad.com.au>
To: Francois Romieu <romieu@zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from server.atrad.com.au ([150.101.241.2]:38810 "EHLO
	server.atrad.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753259Ab3CKARj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Mar 2013 20:17:39 -0400
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

That's fine.  Do I wait for you to ping me about this?

> Take it for what it's worth but I don't test much with PREEMPT, NOHZ or
> SLUB and I never tried all those at the same time.

Fair enough.  I'm not using CONFIG_PREEMPT but NOHZ and SLUB are both in the
mix.  In the meantime I can easily test to see if turning off
CONFIG_PREEMPT_VOLUNTARY, CONFIG_NO_HZ and/or moving to SLAB changes things.
I'll report the findings.

Regards
  jonathan
