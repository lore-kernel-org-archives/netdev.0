From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [net-next PATCH V5] qdisc: bulk dequeue support for qdiscs with
 TCQ_F_ONETXQUEUE
Date: Wed, 1 Oct 2014 00:07:52 +0200
Message-ID: <20141001000752.4e553919@redhat.com>
References: <20140930085114.24043.81310.stgit@dragon>
	<1412077736.30721.54.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Tom Herbert <therbert@google.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Florian Westphal <fw@strlen.de>,
	Daniel Borkmann <dborkman@redhat.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Dave Taht <dave.taht@gmail.com>, toke@toke.dk,
	brouer@redhat.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50594 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750818AbaI3WIO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Sep 2014 18:08:14 -0400
In-Reply-To: <1412077736.30721.54.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 30 Sep 2014 04:48:56 -0700
Eric Dumazet <eric.dumazet@gmail.com> wrote:
 
> In my opinion, you guys missed some opportunities :

This is a conservative first approach.  The merge window is approaching
fast, is is annoying you are blocking a save conservative approach.


> 1) Ideally the algo should try to call validate_xmit_skb() outside of
> the locks (qdisc lock or device lock), because eventually doing checksum
> computation or full segmentation should allow other cpus doing enqueues.

Save it for later please, don't complicate things further.


> 2) TSO support. Have you ideas how to perform this ?

Yes, we already have patches floating which implements bulking of TSO
and GSO packets.  You will get that.

Please one step at a time, also for bisect-ability...

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
