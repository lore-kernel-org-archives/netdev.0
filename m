From: Jonathan Woithe <jwoithe@atrad.com.au>
Subject: Re: r8169 regression: UDP packets dropped intermittantly
Date: Tue, 12 Mar 2013 08:48:39 +1030
Message-ID: <20130311221839.GA19492@marvin.atrad.com.au>
References: <20130309064647.GC4984@marvin.atrad.com.au>
 <20130311000216.GA31808@zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Jonathan Woithe <jwoithe@atrad.com.au>
To: Francois Romieu <romieu@zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from server.atrad.com.au ([150.101.241.2]:50924 "EHLO
	server.atrad.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754017Ab3CKWSx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Mar 2013 18:18:53 -0400
Content-Disposition: inline
In-Reply-To: <20130311000216.GA31808@zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is following up on my response from a few days ago.

On Mon, Mar 11, 2013 at 01:02:16AM +0100, Francois Romieu wrote:
> Jonathan Woithe <jwoithe@atrad.com.au> :
> [...]
> > While we can rely on the retry system to paper over this regression, the
> > behaviour of earlier kernels suggests that there is a real issue at play. 
> > Is there any chance that this can be looked at ?
> :
> Take it for what it's worth but I don't test much with PREEMPT, NOHZ or
> SLUB and I never tried all those at the same time.

I have now run tests to address this comment.  Starting with the kernel
config I originally posted:

 * turn off CONFIG_NO_HZ: problem still present.

 * then turn off PREEMPT settings: problem still present.

 * then change from SLUB to SLAB allocator: problem still present.

In conclusion, the problem still shows when the kernel is configured to use
SLAB without PREEMPT and NOHZ.

Regards
  jonathan
