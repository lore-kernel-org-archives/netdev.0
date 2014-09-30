From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [net-next PATCH] dql: add a burst attribute
Date: Tue, 30 Sep 2014 23:46:42 +0200
Message-ID: <20140930234642.3c08b033@redhat.com>
References: <20140930085114.24043.81310.stgit@dragon>
	<1412080482.30721.68.camel@edumazet-glaptop2.roam.corp.google.com>
	<1412081485.30721.75.camel@edumazet-glaptop2.roam.corp.google.com>
	<20140930134655.GA24565@breakpoint.cc>
	<1412086646.30721.81.camel@edumazet-glaptop2.roam.corp.google.com>
	<20140930143101.GB24565@breakpoint.cc>
	<1412088936.30721.86.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Tom Herbert <therbert@google.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Daniel Borkmann <dborkman@redhat.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Dave Taht <dave.taht@gmail.com>, toke@toke.dk,
	brouer@redhat.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45945 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751170AbaI3VrC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Sep 2014 17:47:02 -0400
In-Reply-To: <1412088936.30721.86.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 30 Sep 2014 07:55:36 -0700
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> On Tue, 2014-09-30 at 16:31 +0200, Florian Westphal wrote:
> > Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > > If you feel not comfortable with "burst", rename it to whatever you
> > > think is best.
> > > But please, do not hard code magic 7 in your code.
> > 
> > I had hoped that this 'magic' value could be removed
> > completely, only using bql data for bulking decisions.
> 
> But it is apparently not the case, since you guys decided to had it set
> to 8, then to 7 later, based on experiments.

The "magic" limit is only a conservative save guard.  We do plan to
remove this completely.  That is the reason for not exporting this, as
we want free-hands to remove this completely.

Guess, I'll remove it completely now, so we can move on.


I would like some off/on switch, exported to userspace, for disabling
this bulking (then we don't need this conservative magic number).  How
would that be done best?

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
