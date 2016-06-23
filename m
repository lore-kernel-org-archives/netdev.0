From: Jonathan Woithe <jwoithe@atrad.com.au>
Subject: Re: r8169 regression: UDP packets dropped intermittantly
Date: Thu, 23 Jun 2016 17:56:12 +0930
Message-ID: <20160623082612.GJ17670@marvin.atrad.com.au>
References: <20151201235852.GA16429@electric-eye.fr.zoreil.com>
 <20160208023318.GJ9174@marvin.atrad.com.au>
 <20160407024417.GE17921@marvin.atrad.com.au>
 <20160517065231.GO30050@marvin.atrad.com.au>
 <20160518065137.GJ27564@marvin.atrad.com.au>
 <20160601003123.GE3384@marvin.atrad.com.au>
 <20160621032133.GC19735@marvin.atrad.com.au>
 <20160621230957.GA19674@electric-eye.fr.zoreil.com>
 <20160621235938.GB13364@marvin.atrad.com.au>
 <20160622232250.GA26424@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from server.atrad.com.au ([150.101.241.2]:52835 "EHLO
	server.atrad.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751613AbcFWI03 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jun 2016 04:26:29 -0400
Content-Disposition: inline
In-Reply-To: <20160622232250.GA26424@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 23, 2016 at 01:22:50AM +0200, Francois Romieu wrote:
> Jonathan Woithe <jwoithe@atrad.com.au> :
> [...]
> > to mainline (in which case I'll keep watching out for it)?  Or is the
> > out-of-tree workaround mentioned above considered to be the long term
> > fix for those who encounter the problem?
> 
> It's a workaround. Nothing less, nothing more.

I see.  Should I assume therefore that a permanent fix *might* get into the
kernel someday, but that there is no timeframe and no guarantee?

I should mention that while I currently have access to hardware to test for
the problem, this may not be the case in a few months time since the
hardware (the computer and network devices) is slated for deployment.

Thank you for helping me to understand what the situation is regarding
intentions for mainline.

> IIRC the ga311 irq signaling was a bit special. I almost surely broke
> it at some point.

While we have seen the current issue on GA311 cards (and this is what is
currently in our test setup), it's also been observed with other r8169-based
cards (a D-Link from memory).

Regards
  jonathan
