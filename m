From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RFC]: napi_struct V5
Date: Tue, 07 Aug 2007 21:08:57 -0700 (PDT)
Message-ID: <20070807.210857.66061101.davem@davemloft.net>
References: <adasl6vq8d1.fsf@cisco.com>
	<20070807.160651.98554604.davem@davemloft.net>
	<adahcnar85j.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@linux-foundation.org,
	jgarzik@pobox.com, hadi@cyberus.ca, rusty@rustcorp.com.au
To: rdreier@cisco.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49033
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750786AbXHHEJA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Aug 2007 00:09:00 -0400
In-Reply-To: <adahcnar85j.fsf@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Roland Dreier <rdreier@cisco.com>
Date: Tue, 07 Aug 2007 20:56:40 -0700

> First, there's pretty much universal agreement that
> patches should only contain one idea ("separate your changes"), that
> cleanups should not be mixed in with other changes, etc, etc.

Fine I'll revert.

> Although frankly, I have to say that your position here doesn't make
> much sense.

I think it does, the inconsistencies shown in each driver were
either 1) unnecessarily being different or 2) causing outright
races and bugs (see the discussions between Rusty and myself
during the first few revisions).

> In your earlier patches that got rid of netif_rx_reschedule(),
> your suggestion on how to handle the missed event race was to ask the
> hardware to trigger another event from the poll routine so it got
> rescheduled.

And I have rescinded this idea, and the removal of the resched
interface, for hardware not capable in response to your feedback.

> Being treated with the same level of collegiality that (I think) I
> treat you with would be appreciated.

My apologies.

I tend to lose it when people get hyper-critical on a change of which
I am doing all of the work editing a large number of drivers and for
which everyone benfits.
