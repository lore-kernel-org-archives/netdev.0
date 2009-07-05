From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [RFC] arp announce, arp_proxy and windows ip conflict verification
Date: Sat, 04 Jul 2009 17:07:11 -0700
Message-ID: <m13a9c2dsg.fsf@fess.ebiederm.org>
References: <200907030246.18054.denys@visp.net.lb>
	<200907041803.25436.denys@visp.net.lb>
	<m13a9c6rhv.fsf@fess.ebiederm.org>
	<200907050100.08148.denys@visp.net.lb>
	<20090705085203.332f0c3b.lk-netdev@lk-netdev.nosense.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Denys Fedoryschenko <denys@visp.net.lb>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Mark Smith <lk-netdev@lk-netdev.nosense.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:60522 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752554AbZGEAHO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Jul 2009 20:07:14 -0400
In-Reply-To: <20090705085203.332f0c3b.lk-netdev@lk-netdev.nosense.org> (Mark Smith's message of "Sun\, 5 Jul 2009 08\:52\:03 +0930")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mark Smith <lk-netdev@lk-netdev.nosense.org> writes:

> On Sun, 5 Jul 2009 01:00:08 +0300
> Denys Fedoryschenko <denys@visp.net.lb> wrote:
>
>> On Sunday 05 July 2009 00:57:32 Eric W. Biederman wrote:
>> >
>> > How can that possibly be a correct network configuration?
>> >
>> > Eric
>> It is a problem to have different networks, who doesn't communicate one with 
>> each other, in same ethernet segment?
>> 
>> Does it violate anything?
>
> I'm pretty sure it doesn't.
>
> It's a common enough situation. A second subnet (or more) is assigned
> to a link because the first isn't large enough, and renumbering the
> hosts into a larger subnet is not practical at the time. A
> 'one-armed router' is used up stream to have traffic go between the
> different subnets, at the cost of traffic double traversing the link.
> (The worst example I've seen is 25 subnets operating this way!)
>
> Fundamentally it is no different to routing traffic to other subnets.
> IP was designed on the assumption that there'd only be a single subnet
> per link, so nothing was done to make this scenario more efficent.
>
> IPv6 has introduced the ability for hosts to be told by their default
> router that destinations they think are "offlink", because the address
> falls outside a locally assigned or learned prefixes, are actually
> "onlink", preventing this double traversing problem.

Multiple subnets on an ethernet segment sure.  Multiple subnets
subnets that don't communicate?  Not telling your router about all of
the subnets on the ethernet segment?

The combination of not configuring the router to know about all of the
subnets and enabling proxy arp is what is causing problems for Denys.

That sure seems like a misconfiguration to me.

Eric
