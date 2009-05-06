From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: bond + tc regression ?
Date: Wed, 6 May 2009 10:48:08 +0000
Message-ID: <20090506104808.GA6115@ff.dom.local>
References: <20090505174135.GA29716@francoudi.com> <20090506061010.GA4571@ff.dom.local> <20090506103616.GA25750@francoudi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <dada1@cosmosbay.com>, netdev@vger.kernel.org
To: Vladimir Ivashchenko <hazard@francoudi.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.226]:58118 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753198AbZEFKsR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 May 2009 06:48:17 -0400
Received: by rv-out-0506.google.com with SMTP id f9so9209rvb.1
        for <netdev@vger.kernel.org>; Wed, 06 May 2009 03:48:17 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20090506103616.GA25750@francoudi.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 06, 2009 at 01:36:16PM +0300, Vladimir Ivashchenko wrote:
> On Wed, May 06, 2009 at 06:10:10AM +0000, Jarek Poplawski wrote:
> 
> > >> ifconfig -a
> > > 
> > > bond0     Link encap:Ethernet  HWaddr 00:1B:24:BD:E9:CC
> > >           inet addr:xxx.xxx.135.44  Bcast:xxx.xxx.135.47  Mask:255.255.255.248
> > >           inet6 addr: fe80::21b:24ff:febd:e9cc/64 Scope:Link
> > >           UP BROADCAST RUNNING MASTER MULTICAST  MTU:1500  Metric:1
> > >           RX packets:436076190 errors:0 dropped:391250 overruns:0 frame:0
> > >           TX packets:2620156321 errors:0 dropped:0 overruns:0 carrier:0
> > >           collisions:0 txqueuelen:0
> > >           RX bytes:4210046233 (3.9 GiB)  TX bytes:2520272242 (2.3 GiB)
> > 
> > Could you try e.g.: ifconfig bond0 txqueuelen 1000
> > before tc qdisc add?
> 
> The drops on ifconfig are not increasing - these numbers are there from some tests made
> before.
> 

I'm not sure what do you mean? IMHO you don't use qdiscs properly,
so any TX problems end with drops. (Older kernel versions could mask
this problem with requeuing.)

Jarek P.
