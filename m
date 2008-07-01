From: Stephen Hemminger <stephen.hemminger@vyatta.com>
Subject: Re: [PATCH 3/3] ip: sysctl documentation cleanup
Date: Tue, 1 Jul 2008 16:13:57 -0700
Message-ID: <20080701161357.3ddccd2f@speedy>
References: <20080701153820.235faa72@extreme>
	<20080701153926.7b3fe1dd@extreme>
	<20080701154306.21b04c75@extreme>
	<Pine.LNX.4.64.0807011549340.26330@shark.he.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: "Randy.Dunlap" <rdunlap@xenotime.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:50129 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751062AbYGAXN5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Jul 2008 19:13:57 -0400
In-Reply-To: <Pine.LNX.4.64.0807011549340.26330@shark.he.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 1 Jul 2008 15:55:05 -0700 (PDT)
"Randy.Dunlap" <rdunlap@xenotime.net> wrote:

> Hi Stephen,
> 
> On Tue, 1 Jul 2008, Stephen Hemminger wrote:
> 
> > Fix some documentation stuff:
> >   * replace non-standard spelling
> >   * remove confusing sentence in F-RTO description. The existing
> >     text is sufficient to explain what the option does
> >   * reorganize and update list of undocumented values
> > 
> > Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> > 
> > --- a/Documentation/networking/ip-sysctl.txt	2008-07-01 14:52:00.000000000 -0700
> > +++ b/Documentation/networking/ip-sysctl.txt	2008-07-01 15:12:26.000000000 -0700
> > @@ -159,7 +159,7 @@ tcp_congestion_control - STRING
> >  	Default is set as part of kernel configuration.
> >  
> >  tcp_dsack - BOOLEAN
> > -	Allows TCP to send "duplicate" SACKs.
> > +	Allows TCP to send "duplicate" SACK's.
> 
> I think that either way is OK for these...
> 
> >  
> >  tcp_ecn - BOOLEAN
> >  	Enable Explicit Congestion Notification in TCP.
> > @@ -185,10 +185,9 @@ tcp_frto - INTEGER
> >  	timeouts.  It is particularly beneficial in wireless environments
> >  	where packet loss is typically due to random radio interference
> >  	rather than intermediate router congestion.  F-RTO is sender-side
> > -	only modification.  Therefore it does not require any support from
> > -	the peer, but in a typical case, however, where wireless link is
> > -	the local access link and most of the data flows downlink, the
> > -	faraway servers should have F-RTO enabled to take advantage of it.
> > +	only modification therefore it does not require any support from
> > +	the peer.
> 
> Run-on sentence :(
> 
> > +
> >  	If set to 1, basic version is enabled.  2 enables SACK enhanced
> >  	F-RTO if flow uses SACK.  The basic version can be used also when
> >  	SACK is in use though scenario(s) with it exists where F-RTO
> > @@ -270,13 +269,13 @@ tcp_mem - vector of 3 INTEGERs: min, pre
> >  	pressure mode, which is exited when memory consumption falls
> >  	under "min".
> >  
> > -	max: number of pages allowed for queueing by all TCP sockets.
> > +	max: number of pages allowed for queuing by all TCP sockets.
> 
> google for "queuing theory" has about 198,000 hits.
> google for "queueing theory" has about 499,000 hits.
> 
> grep kernel source tree for "queuing" has 487 hits.
> grep kernel source tree for "queueing" has 728 hits.

I wouldn't accept either as definitive norm on spelling, but looking at Webster
online, either spelling is now acceptable.  My spellchecker and old dictionary
appear out of date.
