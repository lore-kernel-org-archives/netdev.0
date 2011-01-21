From: Simon Horman <horms@verge.net.au>
Subject: Re: Flow Control and Port Mirroring Revisited
Date: Sat, 22 Jan 2011 10:11:52 +1100
Message-ID: <20110121231149.GI2195@verge.net.au>
References: <AANLkTimO=5HmTJO1kmHGAWa-HTac+3d0TbrmJX5W4hVu@mail.gmail.com>
 <20110113234135.GC8426@verge.net.au>
 <20110114045818.GA29738@redhat.com>
 <20110114063528.GB10957@verge.net.au>
 <20110114065415.GA30300@redhat.com>
 <20110116223728.GA6279@verge.net.au>
 <20110117102655.GH23479@redhat.com>
 <4D35ECE2.4040901@hp.com>
 <20110120083727.GA1807@verge.net.au>
 <20110121095929.GE26070@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rick Jones <rick.jones2@hp.com>, Jesse Gross <jesse@nicira.com>,
	Rusty Russell <rusty@rustcorp.com.au>,
	virtualization@lists.linux-foundation.org, dev@openvswitch.org,
	virtualization@lists.osdl.org, netdev@vger.kernel.org,
	kvm@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:42099 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753361Ab1AUXN4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Jan 2011 18:13:56 -0500
Content-Disposition: inline
In-Reply-To: <20110121095929.GE26070@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 21, 2011 at 11:59:30AM +0200, Michael S. Tsirkin wrote:
> On Thu, Jan 20, 2011 at 05:38:33PM +0900, Simon Horman wrote:
> > [ Trimmed Eric from CC list as vger was complaining that it is too long ]
> > 
> > On Tue, Jan 18, 2011 at 11:41:22AM -0800, Rick Jones wrote:
> > > >So it won't be all that simple to implement well, and before we try,
> > > >I'd like to know whether there are applications that are helped
> > > >by it. For example, we could try to measure latency at various
> > > >pps and see whether the backpressure helps. netperf has -b, -w
> > > >flags which might help these measurements.
> > > 
> > > Those options are enabled when one adds --enable-burst to the
> > > pre-compilation ./configure  of netperf (one doesn't have to
> > > recompile netserver).  However, if one is also looking at latency
> > > statistics via the -j option in the top-of-trunk, or simply at the
> > > histogram with --enable-histogram on the ./configure and a verbosity
> > > level of 2 (global -v 2) then one wants the very top of trunk
> > > netperf from:
> > 
> > Hi,
> > 
> > I have constructed a test where I run an un-paced  UDP_STREAM test in
> > one guest and a paced omni rr test in another guest at the same time.
> 
> Hmm, what is this supposed to measure?  Basically each time you run an
> un-paced UDP_STREAM you get some random load on the network.
> You can't tell what it was exactly, only that it was between
> the send and receive throughput.

Rick mentioned in another email that I messed up my test parameters a bit,
so I will re-run the tests, incorporating his suggestions.

What I was attempting to measure was the effect of an unpaced UDP_STREAM
on the latency of more moderated traffic. Because I am interested in
what effect an abusive guest has on other guests and how that my be
mitigated.

Could you suggest some tests that you feel are more appropriate?

