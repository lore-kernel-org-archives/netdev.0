From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: under-performing bonded interfaces
Date: Thu, 17 Nov 2011 02:51:54 +0000
Message-ID: <1321498314.2885.78.camel@deadeye>
References: <CANj2EbeMRzicixHwrKpCQ3mMqQ1qbyjbRCxpW+CmVRREAhyeRQ@mail.gmail.com>
	 <4EC44ECB.4050201@candelatech.com>
	 <CANj2EbfrtbysEbj+gMa+fOhWo0EWjBXVyGkw8WyiPAV9nPduuQ@mail.gmail.com>
	 <1321491449.2709.90.camel@bwh-desktop>
	 <CANj2Ebdd89=Fk6i4e4Txsb3ANuzz-x4t+tT6CAnWDNZe0zvx9g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Ben Greear <greearb@candelatech.com>, <netdev@vger.kernel.org>
To: Simon Chen <simonchennj@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:53061 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755101Ab1KQCwD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Nov 2011 21:52:03 -0500
In-Reply-To: <CANj2Ebdd89=Fk6i4e4Txsb3ANuzz-x4t+tT6CAnWDNZe0zvx9g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2011-11-16 at 20:38 -0500, Simon Chen wrote:
> Thanks, Ben. That's good discovery...
> 
> Are you saying that both 10G NICs are on the same PCIe x4 slot, so
> that they're subject to the 12G throughput bottleneck?

I assumed you were using 2 ports on the same board, i.e. the same slot.
If you were using 1 port each of 2 boards then I would have expected
them both to be usable at full speed.  So far as I can remember, PCIe
bridges are usually set up so there isn't contention for bandwidth
between slots.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
