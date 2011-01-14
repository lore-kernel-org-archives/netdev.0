From: Daniel Hellstrom <daniel@gaisler.com>
Subject: Re: [PATCH 03/10] GRETH: added no_gbit option
Date: Fri, 14 Jan 2011 08:51:43 +0100
Message-ID: <4D30008F.5050100@gaisler.com>
References: <1294907135-24884-1-git-send-email-daniel@gaisler.com>	<1294907135-24884-3-git-send-email-daniel@gaisler.com> <20110113.221324.82807816.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kristoffer@gaisler.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail175c2.megamailservers.com ([69.49.111.75]:44183 "EHLO
	mail175c2.megamailservers.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751134Ab1ANHvx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Jan 2011 02:51:53 -0500
In-Reply-To: <20110113.221324.82807816.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:

>From: Daniel Hellstrom <daniel@gaisler.com>
>Date: Thu, 13 Jan 2011 09:25:28 +0100
>
>  
>
>>For debug only. The driver does not report that it is GBit capable, instead
>>it will report 10/100 mode to the generic PHY layer.
>>
>>Signed-off-by: Daniel Hellstrom <daniel@gaisler.com>
>>    
>>
>
>You may not add special purpose module parameters to your ethernet driver.
>
>Instead, users can use ethtool to control what speeds the device will
>try to advertise for during auto-negotiation, or use with a fixed
>link configuration.
>  
>
Ok, I will remove this patch.

Daniel

