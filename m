From: Dmitry Yusupov <dima@neterion.com>
Subject: RE: Linux support for RDMA
Date: Fri, 01 Apr 2005 16:02:37 -0800
Message-ID: <1112400157.9559.98.camel@beastie>
References: <67D69596DDF0C2448DB0F0547D0F947E01781F1A@yogi.asicdesigners.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: jaganav@us.ibm.com, "H. Peter Anvin" <hpa@zytor.com>,
        Roland Dreier <roland@topspin.com>, open-iscsi@googlegroups.com,
        "David S. Miller" <davem@davemloft.net>, mpm@selenic.com,
        andrea@suse.de, michaelc@cs.wisc.edu,
        James.Bottomley@HansenPartnership.com, ksummit-2005-discuss@thunk.org,
        netdev@oss.sgi.com, Benjamin LaHaise <bcrl@kvack.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Asgeir Eiriksson <asgeir@chelsio.com>
In-Reply-To: <67D69596DDF0C2448DB0F0547D0F947E01781F1A@yogi.asicdesigners.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 2005-04-01 at 15:50 -0800, Asgeir Eiriksson wrote:
> Venkat
> 
> Your assessment of the IB vs. Ethernet latencies isn't necessarily
> correct.
> - you already have available low latency 10GE switches (< 1us
> port-to-port)
> - you already have available low latency (cut-through processing) 10GE
> TOE engines
> 
> The Veritest verified 10GE TOE end-to-end latency is < 10us today
> (end-to-end being from a Linux user-space-process to a Linux
> user-space-process through a switch; full report with detail of the
> setup is available at
> http://www.chelsio.com/technology/Chelsio10GbE_Fujitsu.pdf)
> 
> For comparison: the published IB latency numbers are around 5us today
> and those use a polling receiver, and those don't include a context
> switch(es) as does the Ethernet number quoted above.

yep. I should agree in here. On 10Gbps network latencies numbers are
around 5-15us. Even with non-TOE card, I managed to get 13us latency
with regular TCP/IP stack.

[root@localhost root]# ./nptcp -a -t -l 256 -u 98304 -i 256 -p 5100 -P - h 17.1.1.227
Latency: 0.000013
Now starting main loop
  0:       256 bytes    7 times -->  131.37 Mbps in 0.000015 sec
  1:       512 bytes   65 times -->  239.75 Mbps in 0.000016 sec

Dima

> 'Asgeir
> 
> 
> > -----Original Message-----
> > From: netdev-bounce@oss.sgi.com [mailto:netdev-bounce@oss.sgi.com] On
> > Behalf Of jaganav@us.ibm.com
> > Sent: Thursday, March 31, 2005 5:49 PM
> > To: H. Peter Anvin
> > Cc: Roland Dreier; Dmitry Yusupov; open-iscsi@googlegroups.com; David
> S.
> > Miller; mpm@selenic.com; andrea@suse.de; michaelc@cs.wisc.edu;
> > James.Bottomley@HansenPartnership.com; ksummit-2005-discuss@thunk.org;
> > netdev@oss.sgi.com; Benjamin LaHaise
> > Subject: Re: Linux support for RDMA
> > 
> > Quoting "H. Peter Anvin" <hpa@zytor.com>:
> > > Benjamin LaHaise wrote:
> > > >
> > > > I'm curious how the 10Gig ethernet market will pan out.  Time and
> > again
> > > > the market has shown that ethernet always has the cost advantage
> in
> > the
> > > > end.  If something like Intel's I/O Acceleration Technology makes
> it
> > > > that much easier for commodity ethernet to achieve similar
> performance
> > > > characteristics over ethernet to that of IB and fibre channel, the
> > cost
> > > > advantage alone might switch some new customers over.  But the
> > hardware
> > > > isn't near what IB offers today, making IB an important niche
> filler.
> > > >
> > >
> > >  From what I've seen coming down the pipe, I think 10GE is going to
> > > eventually win over IB, just like previous generations did over
> Token
> > > Ring, FDDI and other niche filler technologies.  It doesn't, as you
> say,
> > > mean that e.g. IB doesn't matter *now*; furthermore, it also matters
> for
> > > the purpose of fixing the kind of issues that are going to have to
> be
> > > fixed anyway.
> > >
> > > 	-hpa
> > >
> > >
> > >
> > 
> > No doubt, Ethernet will eventually win .. btw, Hasn't history proven
> this
> > over
> > ATM? More specifically when the industry predicted that ATM will
> replace
> > ethernet :)
> > 
> > However, I'll have to agree with Ben that IB technolgy will fill an
> > important
> > niche segment, more specifically so in the low end of High Performance
> > Computing
> > (HPC) segment which is in a transition mode currently moving away from
> > proprietary interconnects to industry standards based IB technology.
> > Eventhough,
> > ethernet may eventually may catch up with IB in terms of the bandwidth
> but
> > IB
> > fabrics can offer better latencies.
> > 
> > Thanks
> > Venkat
> 
> 
> 
> 
