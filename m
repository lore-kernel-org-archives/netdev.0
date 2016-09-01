From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH] softirq: let ksoftirqd do its job
Date: Thu, 1 Sep 2016 13:53:56 +0200
Message-ID: <20160901115356.GT10153@twins.programming.kicks-ass.net>
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
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
        David Miller <davem@davemloft.net>,
        Rik van Riel <riel@redhat.com>,
        Paolo Abeni <pabeni@redhat.com>,
        Hannes Frederic Sowa <hannes@redhat.com>,
        linux-kernel <linux-kernel@vger.kernel.org>,
        netdev <netdev@vger.kernel.org>, Jonathan Corbet <corbet@lwn.net>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:41413 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754432AbcIALx7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Sep 2016 07:53:59 -0400
Content-Disposition: inline
In-Reply-To: <20160901130231.58355405@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 01, 2016 at 01:02:31PM +0200, Jesper Dangaard Brouer wrote:
>    PID  S  %CPU     TIME+  COMMAND
>      3  R  50.0  29:02.23  ksoftirqd/0
>  10881  R  10.7   1:01.61  udp_sink
>  10837  R  10.0   1:05.20  udp_sink
>  10852  S  10.0   1:01.78  udp_sink
>  10862  R  10.0   1:05.19  udp_sink
>  10844  S   9.7   1:01.91  udp_sink
> 
> This is strange, why is ksoftirqd/0 getting 50% of the CPU time???

Do you run your udp_sink thingy in a cpu-cgroup?
