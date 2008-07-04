From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [RFC] support for IEEE 1588
Date: Thu, 03 Jul 2008 17:15:03 -0700
Message-ID: <486D6B87.9030409@hp.com>
References: <200807040147.11148.opurdila@ixiacom.com>	<20080703162428.55d9f345@extreme> <200807040240.04801.opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>, netdev@vger.kernel.org
To: Octavian Purdila <opurdila@ixiacom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0028.austin.hp.com ([15.216.28.35]:43112 "EHLO
	g1t0028.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753483AbYGDAPF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jul 2008 20:15:05 -0400
In-Reply-To: <200807040240.04801.opurdila@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Octavian Purdila wrote:
> On Friday 04 July 2008, Stephen Hemminger wrote:
> 
> 
>>>1. RX path
>>>- add a new field in skb to keep the hardware stamp (hwstamp)
>>>- add a new socket flag to enable RX stamping
>>>- add a new control message to retrieve the hwstamp from the skb to
>>>user-space application (for UDP and maybe PF_PACKET)
>>
>>The existing skb timestamp is there, and if the hardware supports it, it
>>could be updated by the device driver  I had a version of sky2 that did
>>just that but never fully pushed it upstream because of available time and
>>testing issues.
>>
>>The API's are already there (and used) for timestamping; don't invent
>>new ones.
> 
> 
> Hi Stephen,
> 
> Thanks for taking the time to respond.
> 
> The hardware we will be using will not have the timestamping unit synchronized 
> to gettimeofday(). In this conditions, is it OK to put our hw stamp into 
> skb->tstamp?

I've not had a good emily litella moment in at least a week, so I'll ask 
- if the clock in the hardware generating the timestamp and the clock in 
the host aren't synchronized in _some_ way, what benefit is there to 
putting the hardware's timestamp in there?

rick jones
wonders the extent to which 1588 might enable one-way latency 
measurements in something like netperf...
