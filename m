From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next PATCH] dql: add a burst attribute
Date: Tue, 30 Sep 2014 07:55:36 -0700
Message-ID: <1412088936.30721.86.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20140930085114.24043.81310.stgit@dragon>
	 <1412080482.30721.68.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1412081485.30721.75.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140930134655.GA24565@breakpoint.cc>
	 <1412086646.30721.81.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140930143101.GB24565@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jesper Dangaard Brouer <brouer@redhat.com>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Tom Herbert <therbert@google.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Daniel Borkmann <dborkman@redhat.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Dave Taht <dave.taht@gmail.com>, toke@toke.dk
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f170.google.com ([209.85.192.170]:62257 "EHLO
	mail-pd0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751694AbaI3Ozj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Sep 2014 10:55:39 -0400
Received: by mail-pd0-f170.google.com with SMTP id ft15so3743362pdb.29
        for <netdev@vger.kernel.org>; Tue, 30 Sep 2014 07:55:39 -0700 (PDT)
In-Reply-To: <20140930143101.GB24565@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-09-30 at 16:31 +0200, Florian Westphal wrote:
> Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > If you feel not comfortable with "burst", rename it to whatever you
> > think is best.
> > But please, do not hard code magic 7 in your code.
> 
> I had hoped that this 'magic' value could be removed
> completely, only using bql data for bulking decisions.

But it is apparently not the case, since you guys decided to had it set
to 8, then to 7 later, based on experiments.

This value is probably dependent on the NIC hardware, while BQL
adj_limit is more likely tied to external factors, like latencies to
react to TX IRQ and perform TX completion.
