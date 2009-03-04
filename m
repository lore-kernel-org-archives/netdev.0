From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: Re: [Patch 3/5] Network Drop Monitor: Adding kfree_skb_clean for
	non-drops and modifying end-of-line points for skbs
Date: Wed, 4 Mar 2009 19:51:56 -0300
Message-ID: <20090304225156.GE6392@ghostprotocols.net>
References: <20090304161335.GC6392@ghostprotocols.net> <20090304.130614.127792905.davem@davemloft.net> <20090304224505.GD6392@ghostprotocols.net> <20090304.144722.167821808.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nhorman@tuxdriver.com, netdev@vger.kernel.org,
	kuznet@ms2.inr.ac.ru, pekkas@netcore.fi, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:51120 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751137AbZCDWwn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Mar 2009 17:52:43 -0500
Content-Disposition: inline
In-Reply-To: <20090304.144722.167821808.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em Wed, Mar 04, 2009 at 02:47:22PM -0800, David Miller escreveu:
> From: Arnaldo Carvalho de Melo <acme@redhat.com>
> Date: Wed, 4 Mar 2009 19:45:05 -0300
> 
> > hasta_la_vista_skbaby()
> 
> This is my personal favorite, it's very Mexifornia.

ROTFL, I have to get that book someday... For now I'm reading a brick
about post-'45 Europe :-)
 
> > consumed_skb()
> 
> But more seriously I like something like "consume_skb()" the best (ie.
> drop the 'd').  It has the implication that an application or other
> entity "consumed" and used the data before we freed the SKB.
> 
> What do you think?

That would be better than kfree_skb_clean, yes.

- Arnaldo

P.S.: Neil, I didn't managed to get to the other aspects of your work,
sorry about being so picky :-\
