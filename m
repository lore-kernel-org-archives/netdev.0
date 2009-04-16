From: David Miller <davem@davemloft.net>
Subject: Re: Network latency regressions from 2.6.22 to 2.6.29
Date: Thu, 16 Apr 2009 15:47:52 -0700 (PDT)
Message-ID: <20090416.154752.185818977.davem@davemloft.net>
References: <alpine.DEB.1.10.0904161151330.13531@qirst.com>
	<1239905279.3203.30.camel@achroite>
	<alpine.DEB.1.10.0904161500020.15835@qirst.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, netdev@vger.kernel.org
To: cl@linux.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46939
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754983AbZDPWsA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Apr 2009 18:48:00 -0400
In-Reply-To: <alpine.DEB.1.10.0904161500020.15835@qirst.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Christoph Lameter <cl@linux.com>
Date: Thu, 16 Apr 2009 15:02:36 -0400 (EDT)

> On Thu, 16 Apr 2009, Ben Hutchings wrote:
> 
>> On Thu, 2009-04-16 at 12:10 -0400, Christoph Lameter wrote:
>> > The following are results of lantency measurements using udpping
>> > (available from http://gentwo.org/ll). It shows that significant latencies
>> > were added since 2.6.27. I surely wish we could get back to times below 90
>> > microseconds.
>> [...]
>>
>> This "90 microseconds" figure is specific to a particular driver and
>> hardware.  Have you verified that it applies to others?  The variation
>> you've reported is tiny compared to the improvements that can be made or
>> lost by hardware tuning.
> 
> The RX delay can influence this of course and so can the driver. But the
> measurements are with the same RX delay and the same driver. Variations
> are up to 20% which is not tiny and its only due to different kernel
> versions.

The driver is changing, and that can also be enough.
