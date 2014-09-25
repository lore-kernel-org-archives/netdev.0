From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [net-next PATCH 1/1 V4] qdisc: bulk dequeue support for qdiscs
 with TCQ_F_ONETXQUEUE
Date: Thu, 25 Sep 2014 10:25:05 +0200
Message-ID: <20140925102505.494acab1@redhat.com>
References: <20140924160932.9721.56450.stgit@localhost>
	<20140924161047.9721.43080.stgit@localhost>
	<1411579395.15395.41.camel@edumazet-glaptop2.roam.corp.google.com>
	<20140924195831.6fb91051@redhat.com>
	<54234225.5000503@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	therbert@google.com, "David S. Miller" <davem@davemloft.net>,
	Alexander Duyck <alexander.h.duyck@intel.com>, toke@toke.dk,
	Florian Westphal <fw@strlen.de>,
	Dave Taht <dave.taht@gmail.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Daniel Borkmann <dborkman@redhat.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	brouer@redhat.com
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53401 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751532AbaIYIZ2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Sep 2014 04:25:28 -0400
In-Reply-To: <54234225.5000503@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 24 Sep 2014 18:13:57 -0400
Jamal Hadi Salim <jhs@mojatatu.com> wrote:

> On 09/24/14 13:58, Jesper Dangaard Brouer wrote:
> > On Wed, 24 Sep 2014 10:23:15 -0700
> > Eric Dumazet <eric.dumazet@gmail.com> wrote:
> >
> 
> >
> >> pktgen is nice, but do not represent the majority of the traffic we send
> >> from high performance host where we want this bulk dequeue thing ;)
> >
> > This patch is actually targetted towards more normal use-cases.
> > Pktgen cannot even use this work, as it bypass the qdisc layer...
> 
> When you post these patches - can you please also post basic performance
> numbers? You dont have to show improvement if it is hard for bulking
> to kick in, but you need to show no harm in at least latency for the
> general use case (i.e not pktgen maybe forwarding activity or something
> sourced from tcp).

I've done measurements with netperf-wrapper:
 http://netoptimizer.blogspot.dk/2014/09/mini-tutorial-for-netperf-wrapper-setup.html

I have already previously posted my measurements here:
 http://people.netfilter.org/hawk/qdisc/
 http://people.netfilter.org/hawk/qdisc/measure01/
 http://people.netfilter.org/hawk/qdisc/experiment01/

Please, see my previous mail where I described each graph.

The above measurements is for 10Gbit/s, but I've also done measurements
on 1Gbit/s driver igb, and 10Mbit/s by forcing igb to use 10Mbit/s.
Those results I forgot upload (and I cannot upload them right now, as
I'm currently in Switzerland).

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
