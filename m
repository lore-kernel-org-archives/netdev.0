From: Christoph Lameter <clameter@sgi.com>
Subject: Re: Possible ways of dealing with OOM conditions.
Date: Fri, 19 Jan 2007 09:54:53 -0800 (PST)
Message-ID: <Pine.LNX.4.64.0701190952090.14617@schroedinger.engr.sgi.com>
References: <20070116132503.GA23144@2ka.mipt.ru>  <1168955274.22935.47.camel@twins>
 <20070116153315.GB710@2ka.mipt.ru>  <1168963695.22935.78.camel@twins>
 <20070117045426.GA20921@2ka.mipt.ru>  <1169024848.22935.109.camel@twins>
 <20070118104144.GA20925@2ka.mipt.ru>  <1169122724.6197.50.camel@twins>
 <20070118135839.GA7075@2ka.mipt.ru>  <1169133052.6197.96.camel@twins>
 <20070118155003.GA6719@2ka.mipt.ru> <1169141513.6197.115.camel@twins>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-mm@kvack.org, David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S964795AbXASRzb@vger.kernel.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <1169141513.6197.115.camel@twins>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 18 Jan 2007, Peter Zijlstra wrote:

> 
> > Cache misses for small packet flow due to the fact, that the same data
> > is allocated and freed  and accessed on different CPUs will become an
> > issue soon, not right now, since two-four core CPUs are not yet to be
> > very popular and price for the cache miss is not _that_ high.
> 
> SGI does networking too, right?

Sslab deals with those issues the right way. We have per processor
queues that attempt to keep the cache hot state. A special shared queue
exists between neighboring processors to facilitate exchange of objects
between then.
