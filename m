From: Patrick McHardy <kaber@trash.net>
Subject: Re: net: use symbolic values for ndo_start_xmit() return codes
Date: Sat, 13 Jun 2009 11:40:39 +0200
Message-ID: <4A337417.30509@trash.net>
References: <4A3280C5.2090101@trash.net> <20090613.011941.261416607.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:33582 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751404AbZFMJkk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Jun 2009 05:40:40 -0400
In-Reply-To: <20090613.011941.261416607.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Patrick McHardy <kaber@trash.net>
> Date: Fri, 12 Jun 2009 18:22:29 +0200
> 
>> This is the final patch for now to get rid of invalid or magic return
>> values in ndo_start_xmit() functions. There are no NETDEV_TX_OK
>> conversions at this time to keep the noise down, but I wouldn't mind
>> doing that as a final step at the end of the merge window.
>>
>> I'll make a final pass over all the drivers before submitting
>> the remaining patches.
> 
> I applied all of this to net-next-2.6 and am doing build testing
> before I push it out to kernel.org
> 
> I highly encourage your NETDEV_TX_OK transformations. :-)

Great, I'll take care of that next week.
