From: Karsten Desler <kdesler@soohrt.org>
Subject: Re: _High_ CPU usage while routing (mostly) small UDP packets
Date: Tue, 7 Dec 2004 19:38:45 +0100
Message-ID: <20041207183845.GA2078@quickstop.soohrt.org>
References: <20041206205305.GA11970@soohrt.org> <20041206134849.498bfc93.davem@davemloft.net> <20041206224107.GA8529@soohrt.org> <41B58A58.8010007@draigBrady.com> <20041207112139.GA3610@soohrt.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: P@draigBrady.com, "David S. Miller" <davem@davemloft.net>,
	netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S261888AbULGSiw@vger.kernel.org>
To: Karsten Desler <kdesler@soohrt.org>
Content-Disposition: inline
In-Reply-To: <20041207112139.GA3610@soohrt.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Karsten Desler <kdesler@soohrt.org> wrote:
> > Also have a look at http://www.hipac.org/ as netfilter
> > has silly scalability properties.
> 
> I did before, but I read on Harald Weltes' weblog that 2.4 gives
> slightly worse pps results than 2.6, and since the cpu usage is as high
> as it is, I didn't want to take any more performance hits.
> I'll try to see what performance impact the netfilter rules have during
> peak load.

using 2 CPUs
System load: 61.4% || Free:  51.0%(0)  26.3%(1)
System load: 59.6% || Free:  53.6%(0)  27.3%(1)
System load: 59.6% || Free:  53.6%(0)  27.3%(1)
System load: 59.7% || Free:  53.6%(0)  27.0%(1)
System load: 60.3% || Free:  53.0%(0)  26.4%(1)
System load: 51.9% || Free:  60.4%(0)  35.8%(1) <- iptables -F
System load: 50.1% || Free:  62.1%(0)  37.7%(1)
System load: 50.1% || Free:  62.0%(0)  37.8%(1)
System load: 50.6% || Free:  61.6%(0)  37.2%(1)
System load: 50.5% || Free:  61.7%(0)  37.3%(1)


> > I also notice that a lot of time is spent allocating
> > and freeing the packet buffers (and possible hidden
> > time due to cache misses due to allocating on one
> > CPU and freeing on another?).
> > How many [RT]xDescriptors do you have configured by the way?
> 
> 256. I increased them to 1024 shortly after the profiling run, but
> didn't notice any change in the cpu usage (will try again with cyclesoak).

Again, no effect.

Cheers,
 Karsten
