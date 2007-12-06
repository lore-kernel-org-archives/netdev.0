From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: TCP event tracking via netlink...
Date: Thu, 6 Dec 2007 13:58:24 +0300
Message-ID: <20071206105823.GA19472@2ka.mipt.ru>
References: <20071205.053031.87154402.davem@davemloft.net> <4756B175.5010108@psc.edu> <20071205144843.GB2623@2ka.mipt.ru> <20071205.210343.57693750.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jheffner@psc.edu, ilpo.jarvinen@helsinki.fi, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:46591 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751885AbXLFK6n (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Dec 2007 05:58:43 -0500
Content-Disposition: inline
In-Reply-To: <20071205.210343.57693750.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 05, 2007 at 09:03:43PM -0800, David Miller (davem@davemloft.net) wrote:
> I think this work is very different.
> 
> When I say "state" I mean something more significant than
> CLOSE, ESTABLISHED, etc. which is what Samir's patches are
> tracking.
> 
> I'm talking about all of the sequence numbers, SACK information,
> congestion control knobs, etc. whose values are nearly impossible to
> track on a packet to packet basis in order to diagnose problems.

I pointed that work as a possible basis for collecting more info if you
needs including sequence numbers, window sizes and so on.
It just requires a useful structure layout placed, so that one would not
require to recreate the same bits again, so that it could be called from
any place inside the stack.

-- 
	Evgeniy Polyakov
