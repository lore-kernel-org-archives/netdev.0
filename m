From: Rick Jones <rick.jones2@hp.com>
Subject: Re: Jumbo frame question...
Date: Fri, 24 Jul 2009 09:39:43 -0700
Message-ID: <4A69E3CF.1040805@hp.com>
References: <200907241141.55097.rgetz@blackfin.uclinux.org> <20090724.093243.201296391.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: rgetz@blackfin.uclinux.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0008.atlanta.hp.com ([15.192.0.45]:40022 "EHLO
	g5t0008.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751239AbZGXQjp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jul 2009 12:39:45 -0400
In-Reply-To: <20090724.093243.201296391.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Robin Getz <rgetz@blackfin.uclinux.org>
> Date: Fri, 24 Jul 2009 11:41:55 -0400
> 
>>Should a gigabit card, configured as 100, be sending jumbo UDP frames?
>>
>>My understanding, is no - this is a spec violation..

In so far as there is no de jure spec for Jumbo Frames, it is rather difficult 
to have a spec violation :).

> There is nothing wrong with supporting jumbo frames
> when the speed is lower than 1GB.
> 
> If you configure the MTU to be jumbo size, it should
> be no surprise to you that this is what gets used.

Not a case of too much rope?  Given that (IIRC) Jumbo Frame was not introduced 
in Ethernet NICs until Gigabit came along (eg Alteon), the chances a (legacy) 
100 Mbit/s network would have JF-capable NICs is epsilon.

rick jones

> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

