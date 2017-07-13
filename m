From: Dave Jones <davej@codemonkey.org.uk>
Subject: Re: sctp refcount bug.
Date: Thu, 13 Jul 2017 10:56:56 -0400
Message-ID: <20170713145656.q3mvzohpzmg2mawe@codemonkey.org.uk>
References: <20170713143639.kbfqyasw4z4kjzsf@codemonkey.org.uk>
 <20170713143834.GU18138@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Vlad Yasevich <vyasevich@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>, linux-sctp@vger.kernel.org
To: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from scorn.kernelslacker.org ([45.56.101.199]:51886 "EHLO
        scorn.kernelslacker.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751193AbdGMO47 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 13 Jul 2017 10:56:59 -0400
Content-Disposition: inline
In-Reply-To: <20170713143834.GU18138@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 13, 2017 at 11:38:34AM -0300, Marcelo Ricardo Leitner wrote:
 > On Thu, Jul 13, 2017 at 10:36:39AM -0400, Dave Jones wrote:
 > > Hit this on Linus' current tree.
 > > 
 > > 
 > > refcount_t: underflow; use-after-free.
 > 
 > Any tips on how to reproduce this?

Only seen it once so far. Will see if I can narrow it down if it
reproduces.  It took ~12 hours of fuzzing to find overnight.

	Dave
