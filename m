From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH] ipv6-multicast: Fix memory leak in input path.
Date: Tue, 27 Sep 2011 12:34:42 -0700
Message-ID: <4E822552.7000401@candelatech.com>
References: <1317149897-14932-1-git-send-email-greearb@candelatech.com> <20110927.151616.1706187903528893128.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:54670 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752659Ab1I0Ten (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Sep 2011 15:34:43 -0400
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

Thanks.

This bug was introduced in 2.6.35, I believe, so should probably send
this to stable as well.

Thanks,
Ben

> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
