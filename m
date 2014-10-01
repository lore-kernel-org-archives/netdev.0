From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [net-next PATCH V5] qdisc: bulk dequeue support for qdiscs with
 TCQ_F_ONETXQUEUE
Date: Wed, 01 Oct 2014 16:05:31 -0400
Message-ID: <542C5E8B.7070204@mojatatu.com>
References: <20140930085114.24043.81310.stgit@dragon>	<542A8EF9.10403@mojatatu.com>	<20140930.142038.235338672810639160.davem@davemloft.net>	<542BFEF3.7020302@mojatatu.com>	<CA+mtBx8rVu9FXtnc18n22L9LP=t=3Pso7U2yvvLcnny57w8aXg@mail.gmail.com>	<542C1F1F.90404@mojatatu.com>	<20141001192840.5679a671@redhat.com>	<542C4E0D.4050404@mojatatu.com> <20141001214700.18b16387@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <therbert@google.com>,
	David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Florian Westphal <fw@strlen.de>,
	Daniel Borkmann <dborkman@redhat.com>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Dave Taht <dave.taht@gmail.com>,
	=?windows-1252?Q?Toke_H=F8iland-J=F8rgensen?= <toke@toke.dk>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f173.google.com ([209.85.213.173]:60363 "EHLO
	mail-ig0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751732AbaJAUFe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Oct 2014 16:05:34 -0400
Received: by mail-ig0-f173.google.com with SMTP id h18so919005igc.0
        for <netdev@vger.kernel.org>; Wed, 01 Oct 2014 13:05:34 -0700 (PDT)
In-Reply-To: <20141001214700.18b16387@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/01/14 15:47, Jesper Dangaard Brouer wrote:

>
> Answer is yes.  It is very easy with simple netperf TCP_STREAM to cause
> queueing >1 packet in the qdisc layer.

If that is the case, I withdraw any doubts i had.
Can you please specify this in your commit logs for patch 0?

> If tuned (according to my blog,
> unloading netfilter etc.) then a single netperf TCP_STREAM will max out
> 10Gbit/s and cause a standing queue.
>

You should describe such tuning in the patch log (hard to read
blogs for more than 30 seconds; write a paper if you want to provide
more details).

> I'm monitoring backlog of qdiscs, and I always see >1 backlog, I never
> saw a standing queue of 1 packet in my testing.  Either the backlog
> area is high 100-200 packets, or 0 backlog.  (With fake pktgen/trafgen
> style tests, it's possible to cause 1000 backlog).

It would be nice to actually collect such stats. Monitoring the backlog
via dumping qdisc stats is a good start - but actually keeping traces
of average bulk size is more useful.

cheers,
jamal
