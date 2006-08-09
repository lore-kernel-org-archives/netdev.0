From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [PATCH 2/2] [IPV4] route: Dynamic hash table sizing.
Date: Wed, 9 Aug 2006 14:18:13 +0400
Message-ID: <20060809101812.GA13336@2ka.mipt.ru>
References: <20060809.004920.59469729.davem@davemloft.net> <20060809.005337.104642177.davem@davemloft.net> <200608091209.29231.dada1@cosmosbay.com> <44D9B51B.5060004@tls.msk.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:56464 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S1030643AbWHIKSc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Aug 2006 06:18:32 -0400
To: Michael Tokarev <mjt@tls.msk.ru>
Content-Disposition: inline
In-Reply-To: <44D9B51B.5060004@tls.msk.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 09, 2006 at 02:12:43PM +0400, Michael Tokarev (mjt@tls.msk.ru) wrote:
> On Wednesday 09 August 2006 09:53, David Miller wrote:
> []
> > -       mult = ((u64)ip_rt_gc_interval) << long_log2(hmask + 1);
> > +       mult = ((u64)(hmask + 1)) << (u64)ip_rt_gc_interval;
> 
> Hmm.. shift *by* a 64-bit number?

I think it is done to shut compiler up.                                                                                                                                             
But nevertheless ip_rt_gc_interval is 15000 on my machine.

> /mjt

-- 
	Evgeniy Polyakov
