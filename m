From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: Re: [PATCH 1/2] IPV6: ICMP6_MIB_OUTMSGS increment duplicated
Date: Mon, 21 Jan 2008 18:59:43 +0800
Message-ID: <47947B1F.7080709@cn.fujitsu.com>
References: <478DD57B.6020503@cn.fujitsu.com>	<479469F8.4010203@cn.fujitsu.com> <20080121.025722.147904573.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: dlstevens@us.ibm.com, netdev@vger.kernel.org,
	herbert@gondor.apana.org.au
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:58526 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752013AbYAULBO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Jan 2008 06:01:14 -0500
In-Reply-To: <20080121.025722.147904573.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller said the following on 2008-1-21 18:57:
>> [IPV6]: ICMP6_MIB_OUTMSGS increment duplicated
>>
>> icmpv6_send() calls ip6_push_pending_frames() indirectly.
>> Both ip6_push_pending_frames() and icmpv6_send() increment
>> counter ICMP6_MIB_OUTMSGS.
>>
>> This patch remove the increment from icmpv6_send.
>>
>> Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
> 
> Which tree are these two changes targetted at?
> 
> 

Dave, because the network of my working place can't clone git
tree, I used 2.6.24-rc8 to make the patches.
Can you apply them to net-2.6 tree?

