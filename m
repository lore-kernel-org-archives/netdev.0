From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH] tcp_v4_send_reset: binding oif to iif in no sock case
Date: Sat, 04 Feb 2012 17:52:45 -0800
Message-ID: <4F2DE0ED.7020708@candelatech.com>
References: <RE:_[PATCH]_tcp:_RST:_binding_oif_to_iif_for_tcp_v4> <1328390556-14906-1-git-send-email-shawn.lu@ericsson.com> <20120204.162602.1922697409850241775.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: shawn.lu@ericsson.com, eric.dumazet@gmail.com,
	netdev@vger.kernel.org, xiaoclu@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:53658 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752958Ab2BEBwz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Feb 2012 20:52:55 -0500
In-Reply-To: <20120204.162602.1922697409850241775.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/04/2012 01:26 PM, David Miller wrote:
> From: Shawn Lu<shawn.lu@ericsson.com>
> Date: Sat, 4 Feb 2012 13:22:36 -0800
>
>> +	/*
>> +	 * When socket is gone, all binding information is lost.
>> +	 * routing might fail in this case. using iif for oif to
>> +	 * make sure we can deliver it
>> +	 */
>
> Comment is poorly formatted, and I'm getting tired of teaching
> people
>
> 	/* That comments are formatted like
> 	 * this.
> 	 */
>
> 	/*
> 	 * Not like this.
> 	 */

I agree with your taste in comments, but the linux style guide
says basically the opposite.  Maybe see if you can sneak a patch
into the style guide? :)

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
