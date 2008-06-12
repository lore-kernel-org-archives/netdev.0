From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: 2.6.25rc7 lockdep trace
Date: Thu, 12 Jun 2008 07:47:57 +0000
Message-ID: <20080612074756.GC4005@ff.dom.local>
References: <20080610.224023.116817726.davem@davemloft.net> <20080612061334.GA4005@ff.dom.local> <20080612.000153.30878828.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: johannes@sipsolutions.net, davej@codemonkey.org.uk,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yw-out-2324.google.com ([74.125.46.31]:47335 "EHLO
	yw-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752614AbYFLHoA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jun 2008 03:44:00 -0400
Received: by yw-out-2324.google.com with SMTP id 9so2150554ywe.1
        for <netdev@vger.kernel.org>; Thu, 12 Jun 2008 00:43:49 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080612.000153.30878828.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 12, 2008 at 12:01:53AM -0700, David Miller wrote:
...
> net: Eliminate flush_scheduled_work() calls while RTNL is held.
> 
...

Very nice!

BTW, I guess this cassini fix with direct calling the work function
(and maybe moving flush_ after unregister_netdev() in 8139too, like
in a few other places) could be re-considered here as well.

Jarek P.
