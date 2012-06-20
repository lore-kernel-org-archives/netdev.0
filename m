From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: 10GBE performance drop with net.ipv4.tcp_timestamps=0
Date: Wed, 20 Jun 2012 13:08:34 +0200
Message-ID: <1340190514.4604.863.camel@edumazet-glaptop>
References: <4FE0EA33.1000309@profihost.ag>
	 <1340141493.4604.773.camel@edumazet-glaptop>
	 <4FE17522.5050005@profihost.ag>
	 <1340176940.4604.801.camel@edumazet-glaptop>
	 <4FE1881B.7030800@profihost.ag>
	 <1340181676.4604.838.camel@edumazet-glaptop>
	 <4FE192A1.6000000@profihost.ag>  <4FE193FA.5030802@profihost.ag>
	 <1340183854.4604.847.camel@edumazet-glaptop>
	 <4FE196F4.3040900@profihost.ag>
	 <1340184528.4604.849.camel@edumazet-glaptop>
	 <4FE198FE.5050202@profihost.ag>
	 <1340185645.4604.853.camel@edumazet-glaptop>
	 <4FE19CFC.8030408@profihost.ag>
	 <1340186788.4604.857.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Stefan Priebe - Profihost AG <s.priebe@profihost.ag>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:63056 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752532Ab2FTLIk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jun 2012 07:08:40 -0400
Received: by bkcji2 with SMTP id ji2so6025405bkc.19
        for <netdev@vger.kernel.org>; Wed, 20 Jun 2012 04:08:38 -0700 (PDT)
In-Reply-To: <1340186788.4604.857.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-06-20 at 12:06 +0200, Eric Dumazet wrote:
> On Wed, 2012-06-20 at 11:50 +0200, Stefan Priebe - Profihost AG wrote:
> > Am 20.06.2012 11:47, schrieb Eric Dumazet:
> > > On Wed, 2012-06-20 at 11:33 +0200, Stefan Priebe - Profihost AG wrote:
> > >
> > >> Sure. In that case i get 4Gbit/s in both variants. I also tried two
> > >> other different machines same result.
> > >>
> > >
> > > So 3.5 on receiver is the problem, it seems ?
> > Yes.
> > 
> > > And you checked all the stuff about irq affinities, i presume, since a
> > > lot of things might have changed between 2.6.32 and 3.5 ?
> > 
> > It is a single core E5 Xeon - i've set the affinity like this:
> 
> And you still have the retransmits in "netstat -s" output ?
> 
> Might be a firmware or pci issue, I have same cards but no problem here.
> 
> Check LRO is on ?
> 
> ethtool -k eth2
> 


Ah, your ethtool -S gives strange fdir_miss counts, you should ask Intel
guys help maybe...
