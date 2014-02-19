From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH -next] net: tcp: add mib counters to track zero window transitions
Date: Wed, 19 Feb 2014 19:59:49 +0100
Message-ID: <20140219185949.GA1179@order.stressinduktion.org>
References: <1392674268-26005-1-git-send-email-fw@strlen.de> <20140219.131708.562226572566677127.davem@davemloft.net> <1392835787.18849.11.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: David Miller <davem@davemloft.net>, fw@strlen.de,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:38961 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754833AbaBSS7v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Feb 2014 13:59:51 -0500
Content-Disposition: inline
In-Reply-To: <1392835787.18849.11.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 19, 2014 at 10:49:47AM -0800, Eric Dumazet wrote:
> On Wed, 2014-02-19 at 13:17 -0500, David Miller wrote:
> > From: Florian Westphal <fw@strlen.de>
> > Date: Mon, 17 Feb 2014 22:57:48 +0100
> > 
> > > Three counters are added:
> > > - one to track when we went from non-zero to zero window
> > > - one to track the reverse
> > > - one counter incremented when we want to announce zero window.
> > > 
> > > The latter is added because it can show cases where we want to close the
> > > window but can't because we would shrink window.
> > > 
> > > Suggested-by: Eric Dumazet <edumazet@google.com>
> > > Signed-off-by: Florian Westphal <fw@strlen.de>
> > > ---
> > >  Eric, is this what you had in mind?
> > > 
> > >  I re-ran my 'slow-sender-with-reader-that-does-not-drain-socket'
> > >  scenario and, as expected, only TCPWANTZEROWINDOW increases.
> > 
> > Eric, ping?
> 
> Thanks, I missed this patch. Let me think about it, thanks !

We need NET_INC_STATS instead of NET_INC_STATS_BH, no?

Greetings,

  Hannes
