From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Passive OS fingerprinting.
Date: Tue, 1 Jul 2008 18:14:12 +0400
Message-ID: <20080701141412.GA30644@2ka.mipt.ru>
References: <20080701113927.GA16343@2ka.mipt.ru> <486A1AC7.9020706@trash.net> <20080701120320.GA9412@2ka.mipt.ru> <486A2487.2010303@trash.net> <20080701130835.GA29223@2ka.mipt.ru> <486A3426.3000807@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:59632 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756652AbYGAONz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Jul 2008 10:13:55 -0400
Content-Disposition: inline
In-Reply-To: <486A3426.3000807@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 01, 2008 at 03:41:58PM +0200, Patrick McHardy (kaber@trash.net) wrote:
> >Actually worm detection is one of the use cases - I was told about
> >successful installations several years ago.
> 
> How does that work? I assume in combination with some kind of
> rate-limit?

IIRC during worm attacks all windows (according to OSF) traffic
was just routed via slow/shaped device (that was forwarding on
a gateway with appropriate NAT). Right now I would recomment to
use recent/rateest module to make fine-grained tuning of the connection.

> >I am also not sure OSF should live in kernel, but what it does it does
> >good and there is no simple way to do the same with existing
> >functionality. It is possible, but not simple, and definitely not
> >trivial for administrator :)
> 
> I don't like the current way such things are implemented in iptables
> (have all logic in the kernel instead of just providing a mechanism
> for implementing it in userspace and presenting a nice view to the
> administrator). Thats not your fault of course and your module is
> also not the first one to do this.

I bet it is not the last one :)

> Unfortunately its most likely not possible to convince me to like
> this, so lets just say that I'm fine with merging it if someone
> speaks up in favour of it :)

Cool. If no none will reply, nothing actually changes :)
OSF lived on its own all the time except several months in patch-o-matic
and then its next generation.

> >There was no nfnetlink either 5 years ago, when OSF was created,
> >this release is just subsequent update to the project.
> >At some moment OSF shared netlink group with ulog, but it was
> >considered harmful, so I dropped support. Netlink usage is
> >rather trivial: it just sends information about matched packt to
> >userspace, so it can block it on its own, rise a message in the window
> >or perform some other steps. Nothing exceptionally complex :)
> >  
> 
> Yes, but I don't want to add another interface netfilter userspace
> has to know about. It should either use nfnetlink and remove the proc
> interface, or remove the connector interface and use proc.
> Preferrably the former.

It uses proc to load rules - I do not like it either, but it was the
simplest way to do so :)

-- 
	Evgeniy Polyakov
