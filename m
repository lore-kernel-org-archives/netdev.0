From: Mark Smith <lk-netdev@lk-netdev.nosense.org>
Subject: Re: [PATCH] bridge: make bridge-nf-call-*tables default
 configurable
Date: Thu, 2 Jul 2009 06:48:40 +0930
Message-ID: <20090702064840.d187bab6.lk-netdev@lk-netdev.nosense.org>
References: <20090630.201630.134200035.davem@davemloft.net>
	<1246445158.598.30.camel@blaa>
	<4A4B3F9A.9060105@trash.net>
	<20090701.090250.52376308.davem@davemloft.net>
	<4A4B8954.70803@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, markmc@redhat.com,
	netdev@vger.kernel.org, herbert@gondor.apana.org.au
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.adam.net.au ([202.136.110.251]:52005 "EHLO
	smtp2.adam.net.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752326AbZGAVTH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jul 2009 17:19:07 -0400
In-Reply-To: <4A4B8954.70803@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 01 Jul 2009 18:05:40 +0200
Patrick McHardy <kaber@trash.net> wrote:

> David Miller wrote:
> > From: Patrick McHardy <kaber@trash.net>
> > Date: Wed, 01 Jul 2009 12:51:06 +0200
> > 
> >> I agree, this has already caused an endless amount of problems for
> >> users due to the unexpected behaviour and, in some cases, bugs.
> >>
> >> Dave's point is certainly valid as well, until we change the defaults,
> >> distributions can use sysctl.conf. But I think we should move towards
> >> changing the defaults.
> > 
> > You must do this via something like your suggestion, the
> > feature-removal-schedule.txt thing.
> 
> Yes, of course. But I prefer the runtime warning (at least on top),
> my feeling is not many people actually read feature-removal-schedule.
> 

Reviewing my earlier email, I realised I didn't say why I liked it.
Yes, I've been burned by it quite a bit, but that was because I wasn't
aware of it.

I do see a lot of value in it for "layer 3 transparent" firewalling.
Adding a firewall to a network can be a bit of an effort as it may
involve changing the networks routing configuration, and consequently
all the things that involves e.g. renumbering hosts, spitting up
subnets or adding new ones. Being able to insert a layer 3
transparent firewalling device between the upstream router and the
downstream hosts would be far, far easier.

With it being able to firewall bridged PPPoE/PPP traffic, potentially
made it even more useful, although in less common cases. For example, I
have a number of devices at home that are themselves running PPPoE/PPP,
rather than having a single upstream router running it. If I wasn't
confident of the firewalling capabilities of each of those devices, I
could insert a layer 3 transparent iptables firewall, and add another
level of firewalling to the PPPoE/PPP encapsulated traffic.

So, I'd certainly like the feature to stay. It just needs to either not
be on by default, or the default made more obvious and a method added
to make it easy to switch off.

Thanks,
Mark.


