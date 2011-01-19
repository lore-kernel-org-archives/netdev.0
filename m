From: Simon Horman <horms@verge.net.au>
Subject: Re: Flow Control and Port Mirroring Revisited
Date: Wed, 19 Jan 2011 18:11:36 +0900
Message-ID: <20110119091135.GF1960@verge.net.au>
References: <20110113064718.GA17905@verge.net.au>
 <AANLkTimO=5HmTJO1kmHGAWa-HTac+3d0TbrmJX5W4hVu@mail.gmail.com>
 <20110113234135.GC8426@verge.net.au>
 <20110114045818.GA29738@redhat.com>
 <20110114063528.GB10957@verge.net.au>
 <20110114065415.GA30300@redhat.com>
 <20110116223728.GA6279@verge.net.au>
 <20110117102655.GH23479@redhat.com>
 <4D35ECE2.4040901@hp.com>
 <20110118201333.GD18760@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rick Jones <rick.jones2@hp.com>, Jesse Gross <jesse@nicira.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Rusty Russell <rusty@rustcorp.com.au>,
	virtualization@lists.linux-foundation.org, dev@openvswitch.org,
	virtualization@lists.osdl.org, netdev@vger.kernel.org,
	kvm@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:56897 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752651Ab1ASJLl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Jan 2011 04:11:41 -0500
Content-Disposition: inline
In-Reply-To: <20110118201333.GD18760@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 18, 2011 at 10:13:33PM +0200, Michael S. Tsirkin wrote:
> On Tue, Jan 18, 2011 at 11:41:22AM -0800, Rick Jones wrote:
> > >So it won't be all that simple to implement well, and before we try,
> > >I'd like to know whether there are applications that are helped
> > >by it. For example, we could try to measure latency at various
> > >pps and see whether the backpressure helps. netperf has -b, -w
> > >flags which might help these measurements.
> > 
> > Those options are enabled when one adds --enable-burst to the
> > pre-compilation ./configure  of netperf (one doesn't have to
> > recompile netserver).  However, if one is also looking at latency
> > statistics via the -j option in the top-of-trunk, or simply at the
> > histogram with --enable-histogram on the ./configure and a verbosity
> > level of 2 (global -v 2) then one wants the very top of trunk
> > netperf from:
> > 
> > http://www.netperf.org/svn/netperf2/trunk
> > 
> > to get the recently added support for accurate (netperf level) RTT
> > measuremnts on burst-mode request/response tests.
> > 
> > happy benchmarking,
> > 
> > rick jones

Thanks Rick, that is really helpful.

> > PS - the enhanced latency statistics from -j are only available in
> > the "omni" version of the TCP_RR test.  To get that add a
> > --enable-omni to the ./configure - and in this case both netperf and
> > netserver have to be recompiled.
> 
> 
> Is this TCP only? I would love to get latency data from UDP as well.

At a glance, -- -T UDP is what you are after.
