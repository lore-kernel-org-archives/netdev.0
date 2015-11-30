From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v1 1/6] net: Generalize udp based tunnel offload
Date: Sun, 29 Nov 2015 22:22:43 -0500 (EST)
Message-ID: <20151129.222243.2290113258075462913.davem@davemloft.net>
References: <CALx6S36H4eyDg-Vv21X2GaGA+g=KfN6iHX=8uM2isEOnPTjs0Q@mail.gmail.com>
	<20151123171103.00007699@unknown>
	<CALx6S36vQhx+iKP9VcpqPBnN7VjBsgd_dYFOfZ+YHyVa97-ajA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jesse.brandeburg@intel.com, anjali.singhai@intel.com,
	jesse@kernel.org, netdev@vger.kernel.org, kiran.patil@intel.com
To: tom@herbertland.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47903 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750736AbbK3DWp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Nov 2015 22:22:45 -0500
In-Reply-To: <CALx6S36vQhx+iKP9VcpqPBnN7VjBsgd_dYFOfZ+YHyVa97-ajA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <tom@herbertland.com>
Date: Tue, 24 Nov 2015 09:32:11 -0800

>>
>> FWIW, I've brought the issue to the attention of the architects here,
>> and we will likely be able to make changes in this space.  Intel
>> hardware (as demonstrated by your patches) already is able to deal with
>> this de-ossification on transmit.  Receive is a whole different beast.
>>
> Please provide the specifics on why "Receive is a whole different
> beast.". Generic receive checksum is already a subset of the
> functionality that you must have implement to support the protocol
> specific offloads. All the hardware needs to do is calculate the 1's
> complement checksum of the packet and return the value on the to the
> host with that packet. That's it. No parsing of headers, no worrying
> about the pseudo header, no dealing with any encapsulation. Just do
> the calculation, return the result to the host and the driver converts
> this to CHECKSUM_COMPLETE. I find it very hard to believe that this is
> any harder than specific support the next protocol du jour.

+1
