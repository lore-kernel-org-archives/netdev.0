From: kuznet@ms2.inr.ac.ru
Subject: Re: route cache GC monitoring
Date: Fri, 26 Apr 2002 19:25:50 +0400 (MSD)
Sender: owner-netdev@oss.sgi.com
Message-ID: <200204261525.TAA21824@sex.inr.ac.ru>
References: <15561.20004.964497.762468@robur.slu.se>
Mime-Version: 1.0
Cc: davem@redhat.com, hadi@cyberus.ca, netdev@oss.sgi.com, jensl@robur.slu.se
Return-path: <owner-netdev@oss.sgi.com>
To: Robert.Olsson@data.slu.se (Robert Olsson)
In-Reply-To: <15561.20004.964497.762468@robur.slu.se> from "Robert Olsson" at Apr 26, 2 02:55:00 pm
List-Id: netdev.vger.kernel.org

Hello!

> We like to propose four new stats. counters to monitor the garbage process 
> of route cache. This should be useful for tuning and debugging installations 
> which have a large number of flows.

OK.

> Tuning is another business but we have played with max_size and gc_thresh
> there are more tuning knobs.

There exist one more interesting parameter: gc_elasticity,
which is supposed to control length of hash bucket.

Alexey
