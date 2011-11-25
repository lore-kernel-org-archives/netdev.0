From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH net-next 1/2] netem: rate-latency extension
Date: Thu, 24 Nov 2011 21:09:26 -0800
Message-ID: <20111124210926.3e4b7567@s6510.linuxnetplumber.net>
References: <1322156378-23257-1-git-send-email-hagen@jauu.net>
	<1322172898.2872.7.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Hagen Paul Pfeifer <hagen@jauu.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:47851 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750705Ab1KYFJ3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Nov 2011 00:09:29 -0500
In-Reply-To: <1322172898.2872.7.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 24 Nov 2011 23:14:58 +0100
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> I like this patch, this is a useful extension.
> 
> Only point is why you chose ratelatency instead of rate ?
> 
> We want to emulate a real link, and yes, a 1000 bytes packet must be
> delayed _before_ we deliver it to the device, but its a detail of how
> works netem.
> 
> The usual word we use to describe a 1Mbps link is "1Mbps rate" ;

I would rather a new qdisc then add more features to the already complex
netem.  Initially, there where was a rate control built into netem, but
the consensus was to use stacking to do it.
