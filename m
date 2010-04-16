From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH v5] rfs: Receive Flow Steering
Date: Fri, 16 Apr 2010 09:32:06 -0400
Message-ID: <1271424726.4606.42.camel@bigi>
References: <alpine.DEB.1.00.1004152243470.15102@pokey.mtv.corp.google.com>
	 <87r5mf8va9.fsf@basil.nowhere.org>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <therbert@google.com>, davem@davemloft.net,
	netdev@vger.kernel.org, eric.dumazet@gmail.com
To: Andi Kleen <andi@halobates.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from qw-out-2122.google.com ([74.125.92.27]:17083 "EHLO
	qw-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754195Ab0DPNcJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Apr 2010 09:32:09 -0400
Received: by qw-out-2122.google.com with SMTP id 8so824091qwh.37
        for <netdev@vger.kernel.org>; Fri, 16 Apr 2010 06:32:09 -0700 (PDT)
In-Reply-To: <87r5mf8va9.fsf@basil.nowhere.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2010-04-16 at 13:57 +0200, Andi Kleen wrote:

> One thing I've been wondering while reading if this should be made
> socket or SMT aware.
> 
> If you're on a hyperthreaded system and sending a IPI
> to your core sibling, which has a completely shared cache hierarchy,
> might not be the best use of cycles.
> 
> The same could potentially true for shared L2 or shared L3 cache
> (e.g. only redirect flows between different sockets)
> 
> Have you ever considered that?
> 

How are you going to schedule the net softirq on an empty queue if you
do this?
BTW, in my tests sending an IPI to an SMT sibling or to another core
didnt make any difference in terms of latency - still 5 microsecs.
I dont have dual Nehalem where we have to cross QPI - there i suspect
it will be longer than 5 microsecs.

cheers,
jamal

