From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH] ipv6-multicast: Fix memory leak in input path.
Date: Thu, 02 Feb 2012 09:26:33 -0800
Message-ID: <4F2AC749.5070905@candelatech.com>
References: <1317149897-14932-1-git-send-email-greearb@candelatech.com> <20110927.151616.1706187903528893128.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:48074 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756890Ab2BBR0g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Feb 2012 12:26:36 -0500
In-Reply-To: <20110927.151616.1706187903528893128.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/27/2011 12:16 PM, David Miller wrote:
> From: greearb@candelatech.com
> Date: Tue, 27 Sep 2011 11:58:17 -0700
>
>> From: Ben Greear<greearb@candelatech.com>
>>
>> Have to free the skb before returning if we fail
>> the fib lookup.
>>
>> Signed-off-by: Ben Greear<greearb@candelatech.com>
>
> Applied, thanks.

 From what I can tell, this never made it into the 3.0 stable
series.

I know that normally you feed things to stable, but please let me
know if you'd like me to send it to the stable guys instead...

Thanks,
Ben


> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
