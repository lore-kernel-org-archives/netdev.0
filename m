From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [net-next PATCH V5] qdisc: bulk dequeue support for qdiscs with
 TCQ_F_ONETXQUEUE
Date: Thu, 2 Oct 2014 09:44:18 +0200
Message-ID: <20141002094418.37f6ecb4@redhat.com>
References: <20140930085114.24043.81310.stgit@dragon>
	<542A8EF9.10403@mojatatu.com>
	<20140930.142038.235338672810639160.davem@davemloft.net>
	<542BFEF3.7020302@mojatatu.com>
	<CA+mtBx8rVu9FXtnc18n22L9LP=t=3Pso7U2yvvLcnny57w8aXg@mail.gmail.com>
	<542C1F1F.90404@mojatatu.com>
	<20141001192840.5679a671@redhat.com>
	<542C4E0D.4050404@mojatatu.com>
	<20141001214700.18b16387@redhat.com>
	<542C5E8B.7070204@mojatatu.com>
	<20141001223229.6cbaac07@redhat.com>
	<CAA93jw5orK2FeD20zcFpXGkqGa=kF8E-vGtkdUs7vr54R5AE6g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
	Tom Herbert <therbert@google.com>,
	David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Florian Westphal <fw@strlen.de>,
	Daniel Borkmann <dborkman@redhat.com>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Toke =?UTF-8?B?SMO4aWxhbmQtSsO4cmdlbnNlbg==?= <toke@toke.dk>,
	brouer@redhat.com, Florian Fainelli <f.fainelli@gmail.com>
To: Dave Taht <dave.taht@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:6253 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751856AbaJBHoj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Oct 2014 03:44:39 -0400
In-Reply-To: <CAA93jw5orK2FeD20zcFpXGkqGa=kF8E-vGtkdUs7vr54R5AE6g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 1 Oct 2014 22:18:05 -0700 Dave Taht <dave.taht@gmail.com> wrote:

> > I usually also monitors the BQL limits during these tests.
> >
> >  grep -H . /sys/class/net/eth4/queues/tx-*/byte_queue_limits/{inflight,limit}
> >
> > To Toke:
> >  Perhaps we could convince Toke, to add a netperf-wrapper recorder for
> > the BQL inflight and limit?  (It would be really cool to plot together)
> 
> I just added a command line mode and support for timestamped limit and
> inflight output to bqlmon
> 
> Get it here:
> 
> https://github.com/dtaht/bqlmon
>
> That should be sufficient for netperf-wrapper to poll it efficiently.

https://github.com/dtaht/bqlmon/commit/ace44b55e2e521af88ba9927bf30fe615024073d#diff-aacbd6867cca49695bfe76ad2bcd45d1R407

Now, that we are in control of the output format.  I would output
something that is easier to parse for netperf-wrapper, e.g. some json
compliant string (it is future extendable and easy to parse for Toke).
Besides the output format, I like you patch to bqlmon.

Perhaps Toke have an opinion on the output formatting from bqlmon?

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
