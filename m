From: Matheos Worku <Matheos.Worku@Sun.COM>
Subject: Re: NIU - Sun Neptune 10g - Transmit timed out reset (2.6.24)
Date: Mon, 16 Jun 2008 11:09:34 -0700
Message-ID: <4856AC5E.1010206@sun.com>
References: <483CB301.40007@sun.com>
 <20080528.223415.193732490.davem@davemloft.net> <483F46E5.9030707@sun.com>
 <20080530.000009.02995266.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; format=flowed; charset=us-ascii
Content-Transfer-Encoding: 7BIT
Cc: jesper@krogh.cc, yhlu.kernel@gmail.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sca-es-mail-2.Sun.COM ([192.18.43.133]:48267 "EHLO
	sca-es-mail-2.sun.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750717AbYFPSKH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jun 2008 14:10:07 -0400
In-reply-to: <20080530.000009.02995266.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:

>From: Matheos Worku <Matheos.Worku@Sun.COM>
>Date: Thu, 29 May 2008 17:14:29 -0700
>
>  
>
>>Actually what I am suggesting was a workaround for the lack of "TX Ring 
>>Empty" interrupt by not relying on the TX interrupt at all.
>>    
>>
>
>Ahh I see.
>
>Some of the things I talked about in my presentation here in
>Berlin at LinuxTAG yesterday can help mitigate the effects.
>Most of it revolves around batching, and allowing the driver
>to manage the backlog of packets directly when the TX queue
>fills up.
>
>In such a case we could batch the TX queue refill, know how many more
>TX packets we will queue up to the chip right now, and therefore know
>that we can safely set periodic MARK bits and only need to force set
>the MARK bit at the very end.
>
>  
>
>>As for the TX hang, I will try to reproduce the problem and look at
>>the registers for the clue.
>>    
>>
Have been trying but not able to reproduce the timeout. I am using NFS 
V3 with TCP. Are you using UDP by any chance?

Regards
Matheos

>
>Thanks a lot.
>--
>To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html
>Please read the FAQ at  http://www.tux.org/lkml/
>  
>

