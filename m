From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: TCP Pacing
Date: Thu, 14 Sep 2006 10:21:55 +0900
Message-ID: <20060914102155.3a6552db@localhost.localdomain>
References: <200609121958.22820.root@danielinux.net>
	<20060913124152.350cd9b2@localhost.localdomain>
	<200609131018.33231.root@danielinux.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Carlo Caini <ccaini@deis.unibo.it>,
	Rosario Firrincieli <rfirrincieli@arces.unibo.it>,
	Giovanni Pau <gpau@cs.ucla.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:54201 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751314AbWINBWR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Sep 2006 21:22:17 -0400
To: root@danielinux.net
In-Reply-To: <200609131018.33231.root@danielinux.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 13 Sep 2006 10:18:31 +0200
Daniele Lacamera <root@danielinux.net> wrote:

> On Wednesday 13 September 2006 05:41, Stephen Hemminger wrote:
> > Pacing in itself isn't a bad idea, but:
> <cut>
> > * Since it is most useful over long delay links, maybe it should be a 
> route parameter.
>

Look into rtnetlink and how we keep track of route metrics, and
add a new per route state variable. Need to update iproute2 (ip command)
as well.

> What does this mean? Should I move the sysctl switch elsewhere?
> 
> A new (cleaner) patch follows.
> Thanks to you all for your attention & advices.
> 
> Signed-off by: Daniele Lacamera <root@danielinux.net>

You may also want into look into high resolution timer (hrtimer),
the resolution doesn't get finer than HZ without using -rt patches.
But the ktime interface is cleaner than the normal timer math.
