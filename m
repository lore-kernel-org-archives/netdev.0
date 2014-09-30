From: Florian Westphal <fw@strlen.de>
Subject: Re: [net-next PATCH] dql: add a burst attribute
Date: Tue, 30 Sep 2014 15:46:55 +0200
Message-ID: <20140930134655.GA24565@breakpoint.cc>
References: <20140930085114.24043.81310.stgit@dragon>
 <1412080482.30721.68.camel@edumazet-glaptop2.roam.corp.google.com>
 <1412081485.30721.75.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jesper Dangaard Brouer <brouer@redhat.com>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Tom Herbert <therbert@google.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Florian Westphal <fw@strlen.de>,
	Daniel Borkmann <dborkman@redhat.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Dave Taht <dave.taht@gmail.com>, toke@toke.dk
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:34536 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751988AbaI3NrB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Sep 2014 09:47:01 -0400
Content-Disposition: inline
In-Reply-To: <1412081485.30721.75.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <eric.dumazet@gmail.com> wrote:
> From: Eric Dumazet <edumazet@google.com>
> 
> Add a new dql attribute, to control how much packets we are allowed to
> burst from qdisc to device.

I understand the motivation for this, but I find it a bit out-of-place
to have a 'packet' type counter in bql context?

Would it perhaps make more sense to restrict bulk dequeues by an upper
(possibly changeable from userspace) byte counter limit?

Thanks,
Florian
