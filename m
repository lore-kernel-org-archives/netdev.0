From: Daniel Hellstrom <daniel@gaisler.com>
Subject: Re: [PATCH 04/10] GRETH: added greth_compat_mode module parameter
Date: Fri, 14 Jan 2011 09:10:43 +0100
Message-ID: <4D300503.9030709@gaisler.com>
References: <1294907135-24884-1-git-send-email-daniel@gaisler.com>	<1294907135-24884-4-git-send-email-daniel@gaisler.com> <20110113.221454.149673942.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kristoffer@gaisler.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail175c2.megamailservers.com ([69.49.111.75]:42686 "EHLO
	mail175c2.megamailservers.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752865Ab1ANIKx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Jan 2011 03:10:53 -0500
In-Reply-To: <20110113.221454.149673942.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:

>From: Daniel Hellstrom <daniel@gaisler.com>
>Date: Thu, 13 Jan 2011 09:25:29 +0100
>
>  
>
>>The greth_compat_mode option can be used to set a GRETH GBit capable MAC
>>in operate as if the GRETH 10/100 device was found. The GRETH GBit supports
>>TCP/UDP checksum offloading, unaligned frame buffers, scatter gather etc.
>>Enabling this mode allows the developer to test the GRETH 10/100 device
>>without all features mentioned above on a GBit MAC capable of the above.
>>
>>Signed-off-by: Daniel Hellstrom <daniel@gaisler.com>
>>    
>>
>
>No special device specific module parameters please.
>
>What if every single driver author added something like this and they
>all named it something different or made it behave in slightly differing
>ways?
>
>What kind of user experience would that result in?
>
>It would result in a sucky one, which is why we avoid adding all kinds
>of hacky driver specific module options.
>
>Find a generic way to provide this functionality.
>  
>
I understand, it was not ment to be a user-experience, rather a 
developer debugging option. I will probably need an option like this in 
the future to avoid searching a very long time for very old hardware, I 
will try to find an other solution for it in the future.

I will remove the 3 GRETH patches and resubmit the others.

Thanks,
Daniel

