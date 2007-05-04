From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: Re: [PATCH 08/40] mm: kmem_cache_objsize
Date: Fri, 04 May 2007 18:15:55 +0200
Message-ID: <1178295355.24217.49.camel@twins>
References: <20070504102651.923946304@chello.nl>
	 <20070504103157.215424767@chello.nl>
	 <84144f020705040354r5cb74c5fj6cb8698f93ffcb83@mail.gmail.com>
	 <Pine.LNX.4.64.0705040908480.21436@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Pekka Enberg <penberg@cs.helsinki.fi>,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	netdev@vger.kernel.org,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	Thomas Graf <tgraf@suug.ch>,
	David Miller <davem@davemloft.net>,
	James Bottomley <James.Bottomley@steeleye.com>,
	Mike Christie <michaelc@cs.wisc.edu>,
	Andrew Morton <akpm@linux-foundation.org>,
	Daniel Phillips <phillips@google.com>
To: Christoph Lameter <clameter@sgi.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from amsfep20-int.chello.nl ([62.179.120.15]:41541 "EHLO
	amsfep20-int.chello.nl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1031323AbXEDQP6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 May 2007 12:15:58 -0400
In-Reply-To: <Pine.LNX.4.64.0705040908480.21436@schroedinger.engr.sgi.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2007-05-04 at 09:09 -0700, Christoph Lameter wrote:
> On Fri, 4 May 2007, Pekka Enberg wrote:
> 
> > On 5/4/07, Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:
> > > Expost buffer_size in order to allow fair estimates on the actual space
> > > used/needed.
> 
> We already have ksize?

ksize gives the internal size, whereas these give the external size.

I need to know how much space I need to reserve, hence I need the
external size; whereas normally you want to know how much space you have
available, which is what ksize gives.

Didn't we have this discussion last time?

