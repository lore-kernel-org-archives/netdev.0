From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Extensible hashing and RCU
Date: Sat, 17 Feb 2007 16:13:02 +0300
Message-ID: <20070217131302.GA22732@2ka.mipt.ru>
References: <20070204074143.26312.qmail@science.horizon.com> <Pine.LNX.4.61.0702050952590.26852@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: linux@horizon.com, davem@davemloft.net, netdev@vger.kernel.org
To: akepner@sgi.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:59607 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1946704AbXBQNNW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 17 Feb 2007 08:13:22 -0500
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.61.0702050952590.26852@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Feb 05, 2007 at 10:02:53AM -0800, akepner@sgi.com (akepner@sgi.com) wrote:
> On Sat, 4 Feb 2007 linux@horizon.com wrote:
> 
> >I noticed in an LCA talk mention that apprently extensible hashing
> >with RCU access is an unsolved problem.  Here's an idea for solving it.
> >....
> 
> Yes, I have been playing around with the same idea for
> doing dynamic resizing of the TCP hashtable.
> 
> Did a prototype "toy" implementation, and I have a
> "half-finished" patch which resizes the TCP hashtable
> at runtime. Hmmm, your mail may be the impetus to get
> me to finally finish this thing....

Why anyone do not want to use trie - for socket-like loads it has
exactly constant search/insert/delete time and scales as hell.

> -- 
> Arthur
> 
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
	Evgeniy Polyakov
