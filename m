From: Willy Tarreau <w@1wt.eu>
Subject: Re: [TCP bug, regression] stuck distcc connections in latest -git
Date: Thu, 24 Jul 2008 15:01:56 +0200
Message-ID: <20080724130156.GA21489@1wt.eu>
References: <20080724060448.GA10203@elte.hu> <E1KLwlD-0001Ub-00@gondolin.me.apana.org.au> <20080724.022259.113079007.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: herbert@gondor.apana.org.au, mingo@elte.hu, davidn@davidnewall.com,
	torvalds@linux-foundation.org, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	stefanr@s5r6.in-berlin.de, rjw@sisk.pl, ilpo.jarvinen@helsinki.fi
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:1967 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751479AbYGXNDZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Jul 2008 09:03:25 -0400
Content-Disposition: inline
In-Reply-To: <20080724.022259.113079007.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 24, 2008 at 02:22:59AM -0700, David Miller wrote:
> 
> BTW, if someone can contact the Fedora folks, specifically whoever
> added that syncookies enable to /etc/sysctl.conf, and let them know
> that they've set our TCP stack back by 10 years by disabling SACK
> and timestamps, I'd really appreciate it.

But syn cookies should not trigger unless the syn backlog is full, right ?
Anyway, it would also explain why Ingo's running no default MSS (though
it should be correctly negociated by syn cookies).

willy

