From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: unstable 10GBE performance with recent kernels (> 3.0.X)
Date: Mon, 18 Jun 2012 14:51:16 +0200
Message-ID: <1340023876.7491.1153.camel@edumazet-glaptop>
References: <4FDEF34C.808@profihost.ag>
	 <1340012706.7491.770.camel@edumazet-glaptop>
	 <4FDEFD55.7010204@profihost.ag>
	 <1340015143.7491.855.camel@edumazet-glaptop>
	 <4FDF20B2.2010603@profihost.ag>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Stefan Priebe - Profihost AG <s.priebe@profihost.ag>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:50346 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751178Ab2FRMvU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jun 2012 08:51:20 -0400
Received: by eeit10 with SMTP id t10so1549030eei.19
        for <netdev@vger.kernel.org>; Mon, 18 Jun 2012 05:51:19 -0700 (PDT)
In-Reply-To: <4FDF20B2.2010603@profihost.ag>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-06-18 at 14:36 +0200, Stefan Priebe - Profihost AG wrote:
> Am 18.06.2012 12:25, schrieb Eric Dumazet:
> > I would remove all this (pretty old and obsolete) stuff and use standard
> > params.
> OK, thanks. done.
> 
> I've one RHEL6 system (using default 2.6.32 kernel) where only using 
> "ntuple on" results in just 4-5Gbit/s while the others using 3.5.0-rc2 
> are working fine.
> 

OK, then you might play with affinities, that's the only thing that
might need sysadmin tuning (irqbalance needs to be disabled)

> > Only thing you could do is :
> > ethtool -K eth2 ntuple on
> >
> > on both machines
> Thanks that works great and boosts the performance a lot. What does it 
> do? man ethtool doesn't show anything useful.
> 

I am not Intel guy, but you might find some info in :

http://downloadmirror.intel.com/14687/eng/README.txt



> Is this also recommanded for 1Gb/s?
> 

Not sure it's supported on ixgb


> Could you recommend a tcp_congestion_control module? RHEL6 uses cubic by 
> default. Some others use reno or bic.

Hard to tell, there is no generic answer. Default should be fine for
most uses.
