From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH] softirq: let ksoftirqd do its job
Date: Thu, 1 Sep 2016 17:28:02 +0200
Message-ID: <20160901152802.GV10153@twins.programming.kicks-ass.net>
References: <1472665349.14381.356.camel@edumazet-glaptop3.roam.corp.google.com>
 <20160831214043.2f44cf08@redhat.com>
 <1472676150.14381.363.camel@edumazet-glaptop3.roam.corp.google.com>
 <20160831235116.33b1946b@redhat.com>
 <20160901130231.58355405@redhat.com>
 <20160901115356.GT10153@twins.programming.kicks-ass.net>
 <20160901142925.63a5031b@redhat.com>
 <20160901143859.730826ed@redhat.com>
 <20160901124839.GU10153@twins.programming.kicks-ass.net>
 <20160901153042.465b864e@redhat.com>
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
Received: from merlin.infradead.org ([205.233.59.134]:49032 "EHLO
        merlin.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933149AbcIAP2H (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Sep 2016 11:28:07 -0400
Content-Disposition: inline
In-Reply-To: <20160901153042.465b864e@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 01, 2016 at 03:30:42PM +0200, Jesper Dangaard Brouer wrote:
> Still... enabled!
> Hmmm.. more idea how to disable this???

I think you ought to be able to assign yourself to the root cgroup,
something like:

  echo $$ > /cgroup/tasks

or wheverever the cpu-cgroup controller is mounted at.

But its been a fair while since I touched any of that, its not a CONFIG
I have enabled much.
