From: Denys Fedoryshchenko <denys@visp.net.lb>
Subject: Re: [PATCH] tcp: fix ICMP-RTO war
Date: Sun, 7 Feb 2010 12:28:52 +0200
Message-ID: <201002071228.53043.denys@visp.net.lb>
References: <201001271556.16156.denys@visp.net.lb> <201001301535.43469.denys@visp.net.lb> <op.u7cmcnxvp498uc@nexus>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Ilpo =?utf-8?q?J=C3=A4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	Netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Damian Lukowski <damian@tvk.rwth-aachen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosting.visp.net.lb ([194.146.153.11]:33832 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753872Ab0BGK3G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Feb 2010 05:29:06 -0500
In-Reply-To: <op.u7cmcnxvp498uc@nexus>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Saturday 30 January 2010 15:56:37 Damian Lukowski wrote:
> > On Friday 29 January 2010 23:45:35 Damian Lukowski wrote:
> >> Denys Fedoryshchenko schrieb:
> >> > On Friday 29 January 2010 14:13:18 Damian Lukowski wrote:
> >> >> Denys Fedoryshchenko schrieb:
> >> >>> On Wednesday 27 January 2010 14:36:18 you wrote:
> >> >>>> Unless they are for a different connection? We might have to print
> >>
> >> sk
> >>
> >> >>>> (%p) in all those printouts to be sure which maps to which. If a
> >>
> >> peer
> >>
> >> >>>> becomes unreachable, it may well have multiple connections open
> >>
> >> (this
> >>
> >> >>>> was a proxy, iirc?).
> >> >>>
> >> >>> Ok i will try to do that today.
> >> >>>
> >> >>> Most probably different connections, on this proxy i have 10-15k
> >> >>> established connections at peak time.
> >> >
> >> > http://www.nuclearcat.com/files/report1.txt
> >> > http://www.nuclearcat.com/files/report2.txt
> >> >
> >> > Here with %p and sk.
> >>
> >> Ok, thanks for testing.
> >> So it is ec0f3440 causing the trouble. Are there still objections
> >> on the lower bound check in __tcp_set_rto()? Well, I will submit
> >> an updated patch and you can make comments there.
> >
> > There is another sk also. I can catch for more time - there is many
> > different
> > pointers to sk appearing (but not in same time, it is  rare case even
> > with my thousands of connections).
> 
> Hmm, I shouldn't have posted so late yesterday, as I forgot to CC
> you and the others when submitting the patch, amongst the grammar error. :/
> Can you test the patch in
> http://marc.info/?l=linux-netdev&m=126480336216898
> please?
> 
> Damian
> 
Seems no more lower bound violation.
Thanks a lot!
