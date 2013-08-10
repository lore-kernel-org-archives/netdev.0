From: Jussi Kivilinna <jussi.kivilinna@iki.fi>
Subject: Re: [PATCH 1/2] net/usb: catc: allocate URB setup_packet as separate
 buffer
Date: Sat, 10 Aug 2013 10:31:11 +0300
Message-ID: <5205EC3F.3080700@iki.fi>
References: <20130807132629.14001.2370.stgit@localhost6.localdomain6> <20130809.134222.2239756285423925844.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, gregkh@linuxfoundation.org,
	linux-usb@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sirokuusama.dnainternet.net ([83.102.40.133]:49973 "EHLO
	sirokuusama.dnainternet.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757626Ab3HJHbT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Aug 2013 03:31:19 -0400
In-Reply-To: <20130809.134222.2239756285423925844.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09.08.2013 23:42, David Miller wrote:
> From: Jussi Kivilinna <jussi.kivilinna@iki.fi>
> Date: Wed, 07 Aug 2013 16:26:29 +0300
> 
>> URB setup packet must not be allocated as part of larger structure
>> because DMA coherence issues.
>>
>> Patch changes catc to allocate ctrl_dr member as separate buffer.
>>
>> Patch is only compile tested.
>>
>> Cc: <stable@vger.kernel.org>
>> Signed-off-by: Jussi Kivilinna <jussi.kivilinna@iki.fi>
> 
> I absolutely do not agree with your adding the stable CC: tag for
> a patch which has only been compile tested.

Agreed, this was not brightest of ideas. I won't do it again.

-Jussi

> 
> This applies to all of your other patches you submitted in this
> cluster too.
> 
