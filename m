From: David Miller <davem@davemloft.net>
Subject: Re: oops in pskb_expand_head - 3.11.6
Date: Mon, 18 Nov 2013 18:03:39 -0500 (EST)
Message-ID: <20131118.180339.524025236648315435.davem@davemloft.net>
References: <20131118092436.GA3743@minipsycho.orion>
	<20131118222543.GP16541@order.stressinduktion.org>
	<20131118225945.GD3743@minipsycho.orion>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: michele@acksyn.org, netdev@vger.kernel.org
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50589 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751301Ab3KRXDk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Nov 2013 18:03:40 -0500
In-Reply-To: <20131118225945.GD3743@minipsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Mon, 18 Nov 2013 23:59:45 +0100

> Mon, Nov 18, 2013 at 11:25:43PM CET, hannes@stressinduktion.org wrote:
>>On Mon, Nov 18, 2013 at 10:24:36AM +0100, Jiri Pirko wrote:
>>> It goes hand in hand with 6aafeef03b9d9ecf255f3a80ed85ee070260e1ae.
>>> Without 9037c3579a277f3a23ba476664629fda8c35f7c4 skbs that reasm len is
>>> < MTU would not get fragmented which is not desired.
>>
>>Jiri, David, do you see problems adding this to stable? We got a lot of
>>reports because of exactly those kind of crashes in the past.
> 
> At this point, I do not see any reason why not to do it.

I've queued them up for -stable, thanks.
