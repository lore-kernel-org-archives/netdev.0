From: Rick Jones <rick.jones2@hp.com>
Subject: Re: why does skb->tstamp use getnstimeofday?
Date: Mon, 16 Jan 2012 14:05:21 -0800
Message-ID: <4F149F21.70400@hp.com>
References: <op.v74shh18fzo5me@stalin> <1326645750.5287.48.camel@edumazet-laptop> <op.v74z14g2fzo5me@stalin>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org
To: Anatoly Sivov <mm05@mail.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0014.houston.hp.com ([15.201.24.17]:7919 "EHLO
	g4t0014.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932069Ab2APWFX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jan 2012 17:05:23 -0500
In-Reply-To: <op.v74z14g2fzo5me@stalin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/15/2012 09:55 AM, Anatoly Sivov wrote:
> I missed that field tstamp is used for things other than RTT and can be
> even user-spaced with SO_TIMESTAMP.
> However, timekeeper speed up/slow down (due to ntp) can seriously affect
> some congestion avoidance algorithm quality, I guess.
> Am I wrong?

Good question - not sure if we will see anything, but the upcoming 
leap-second might be interesting to watch - though I think contemporary 
NTP addresses that by a big slew rather than a step adjust.  Of course 
it can step-adjust the time on the system, but 99 times out of 10 (*) 
that will be just at system start-up, when there probably will not be 
all that many congestion controlled connections active.  Of course, who 
knows what that 100th out of 10 times will do.

rick jones
* 99 times out of 10 is an expression which if I recall correctly was 
coined or at least repeated by a high-school sports coach to mean 
"virtually all of the time"
