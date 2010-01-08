From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 03/13] stmmac: add the new Header file for stmmac
 platform data
Date: Thu, 07 Jan 2010 17:12:43 -0800 (PST)
Message-ID: <20100107.171243.218081712.davem@davemloft.net>
References: <4B45F10A.3050508@octasic.com>
	<4B45F7A6.5010008@st.com>
	<4B45F88A.2070105@octasic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, netdev@vger.kernel.org
To: jean-hugues.deschenes@octasic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51366
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754578Ab0AHBMf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jan 2010 20:12:35 -0500
In-Reply-To: <4B45F88A.2070105@octasic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jean-Hugues Deschenes <jean-hugues.deschenes@octasic.com>
Date: Thu, 07 Jan 2010 10:06:50 -0500

> 
> 
> Giuseppe CAVALLARO wrote:
>> I can rework this moving the stmmac platform header from
>>  include/linux/stmmac.h
>> to
>>  drivers/net/stmmac/stmmac_plat.h
>>
>> On stlinux kernel the include/linux/stm/platform.h header will include
>> .../../../drivers/net/stmmac/stmmac_plat.h instead of linux/stmmac.h.
>>
>> Any other comments?
>>   
> Nope; I'll let you know if I notice something else.

I've applied this version of the stmmac patches to net-next-2.6.

On the topic of platform data, it should live in a include/linux/foo.h
file, anything else is incredibly messy at the moment.

Send any further changes relative to this patch set.

Thanks.
