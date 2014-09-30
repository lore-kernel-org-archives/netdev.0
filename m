From: Florian Westphal <fw@strlen.de>
Subject: Re: [net-next PATCH] dql: add a burst attribute
Date: Tue, 30 Sep 2014 16:31:01 +0200
Message-ID: <20140930143101.GB24565@breakpoint.cc>
References: <20140930085114.24043.81310.stgit@dragon>
 <1412080482.30721.68.camel@edumazet-glaptop2.roam.corp.google.com>
 <1412081485.30721.75.camel@edumazet-glaptop2.roam.corp.google.com>
 <20140930134655.GA24565@breakpoint.cc>
 <1412086646.30721.81.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Tom Herbert <therbert@google.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Daniel Borkmann <dborkman@redhat.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Dave Taht <dave.taht@gmail.com>, toke@toke.dk
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:34671 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752050AbaI3ObE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Sep 2014 10:31:04 -0400
Content-Disposition: inline
In-Reply-To: <1412086646.30721.81.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <eric.dumazet@gmail.com> wrote:
> If you feel not comfortable with "burst", rename it to whatever you
> think is best.
> But please, do not hard code magic 7 in your code.

I had hoped that this 'magic' value could be removed
completely, only using bql data for bulking decisions.
