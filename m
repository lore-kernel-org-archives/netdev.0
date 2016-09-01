From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH] softirq: let ksoftirqd do its job
Date: Thu, 1 Sep 2016 14:29:25 +0200
Message-ID: <20160901142925.63a5031b@redhat.com>
References: <1472650472.14381.317.camel@edumazet-glaptop3.roam.corp.google.com>
        <1472650688.32433.115.camel@redhat.com>
        <1472652643.14381.320.camel@edumazet-glaptop3.roam.corp.google.com>
        <20160831164216.2901190c@redhat.com>
        <1472661956.14381.335.camel@edumazet-glaptop3.roam.corp.google.com>
        <1472665349.14381.356.camel@edumazet-glaptop3.roam.corp.google.com>
        <20160831214043.2f44cf08@redhat.com>
        <1472676150.14381.363.camel@edumazet-glaptop3.roam.corp.google.com>
        <20160831235116.33b1946b@redhat.com>
        <20160901130231.58355405@redhat.com>
        <20160901115356.GT10153@twins.programming.kicks-ass.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
        David Miller <davem@davemloft.net>,
        Rik van Riel <riel@redhat.com>,
        Paolo Abeni <pabeni@redhat.com>,
        Hannes Frederic Sowa <hannes@redhat.com>,
        linux-kernel <linux-kernel@vger.kernel.org>,
        netdev <netdev@vger.kernel.org>,
        Jonathan Corbet <corbet@lwn.net>, brouer@redhat.com
To: Peter Zijlstra <peterz@infradead.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160901115356.GT10153@twins.programming.kicks-ass.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 1 Sep 2016 13:53:56 +0200
Peter Zijlstra <peterz@infradead.org> wrote:

> On Thu, Sep 01, 2016 at 01:02:31PM +0200, Jesper Dangaard Brouer wrote:
> >    PID  S  %CPU     TIME+  COMMAND
> >      3  R  50.0  29:02.23  ksoftirqd/0
> >  10881  R  10.7   1:01.61  udp_sink
> >  10837  R  10.0   1:05.20  udp_sink
> >  10852  S  10.0   1:01.78  udp_sink
> >  10862  R  10.0   1:05.19  udp_sink
> >  10844  S   9.7   1:01.91  udp_sink
> > 
> > This is strange, why is ksoftirqd/0 getting 50% of the CPU time???  
> 
> Do you run your udp_sink thingy in a cpu-cgroup?

That was also Paolo's feedback (IRC).  I'm not aware of it, but it
might be some distribution (Fedora 22) default thing.

How do I verify/check if I have enabled a cpu-cgroup?

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
