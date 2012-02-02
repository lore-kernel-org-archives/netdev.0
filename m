From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH] ipv6-multicast: Fix memory leak in IPv6 multicast.
Date: Thu, 02 Feb 2012 09:27:18 -0800
Message-ID: <4F2AC776.1030406@candelatech.com>
References: <1316819461-3192-1-git-send-email-greearb@candelatech.com> <20110927.153404.420686663860879218.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:33045 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932548Ab2BBR1T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Feb 2012 12:27:19 -0500
In-Reply-To: <20110927.153404.420686663860879218.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/27/2011 12:34 PM, David Miller wrote:
> From: greearb@candelatech.com
> Date: Fri, 23 Sep 2011 16:11:01 -0700
>
>> From: Ben Greear<greearb@candelatech.com>
>>
>> If reg_vif_xmit cannot find a routing entry, be sure to
>> free the skb before returning the error.
>>
>> Signed-off-by: Ben Greear<greearb@candelatech.com>
>
> Applied.

This one has not made it to 3.0 stable either.

Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
