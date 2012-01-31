From: Shriram Rajagopalan <rshriram@cs.ubc.ca>
Subject: Re: [PATCH V2] net/sched: sch_plug - Queue traffic until an explicit release command
Date: Tue, 31 Jan 2012 08:20:07 -0800
Message-ID: <64B068C1-DE39-4487-9829-31B6B9055B56@cs.ubc.ca>
References: <1327823619-29274-1-git-send-email-rshriram@cs.ubc.ca> <1327934756.2243.3.camel@mojatatu> <313929ea4dca3c8fd6948797e03121a8@localhost> <B99410E5-6E69-425A-913D-272058765A68@cs.ubc.ca> <6790d1d5d8aa930222bbfc2ef6a9d48e@localhost>
Mime-Version: 1.0 (1.0)
Content-Type: text/plain;
	charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
	"\" \" <netdev@vger.kernel.org>" <netdev@vger.kernel.org>,
	BrendanCully <brendan@cs.ubc.ca>
To: Hagen Paul Pfeifer <hagen@jauu.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lpp01m020-f174.google.com ([209.85.217.174]:49169 "EHLO
	mail-lpp01m020-f174.google.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753368Ab2AaQUR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Jan 2012 11:20:17 -0500
Received: by lbom4 with SMTP id m4so20900lbo.19
        for <netdev@vger.kernel.org>; Tue, 31 Jan 2012 08:20:16 -0800 (PST)
In-Reply-To: <6790d1d5d8aa930222bbfc2ef6a9d48e@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2012-01-31, at 7:25 AM, Hagen Paul Pfeifer <hagen@jauu.net> wrote:

> 
> On Mon, 30 Jan 2012 08:47:45 -0800, Shriram Rajagopalan wrote:
> 
>> Could you elaborate a little on the packet-based-unplug ?
>> 
>> I got your earlier comment on "indefinite unplug" until an explicit
>> plug is received. Is that what you mean by packet-based-unplug ?
> 
> Sure, imagine a multihop MANET network. Sometimes we have high-priority
> crosstraffic in the next hop (router). Due to OLSR traffic information we
> know in advance that the next hop is not in the ability to forward our low
> priority packets. With this knowledge we can stop (unplug) local generated
> and forwarded traffic and if the next hop has enough free bandwidth we can
> restart (plug) sending already enqueued packets.
> 

I am assuming you mean stop(plug) and restart (unplug). But I get the idea.
Indefinite buffering (subject to qlimit) and release.

Will work on it. Thanks for the cool example :).

Shriram
> So for us a really simple plug/unplug mechanism is superior. Maybe a
> head-drop FIFO based policy for forwarded traffic but I can provide a patch
> on top of your patch to implement a head-drop policy.
> 
> Hagen
> 
