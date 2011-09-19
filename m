From: Jan Ceuleers <jan.ceuleers@computer.org>
Subject: Re: [PATCH] tcp: fix validation of D-SACK
Date: Mon, 19 Sep 2011 19:29:16 +0200
Message-ID: <4E777BEC.7050600@computer.org>
References: <1316374544.31335.16.camel@edumazet-laptop>	<20110918.210725.2061666096968958448.davem@davemloft.net>	<4E76A36B.4060109@intel.com> <20110918.223744.2195272571175354579.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: zheng.z.yan@intel.com, netdev@vger.kernel.org,
	eric.dumazet@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailrelay001.isp.belgacom.be ([195.238.6.51]:4257 "EHLO
	mailrelay001.isp.belgacom.be" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752862Ab1ISRar (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Sep 2011 13:30:47 -0400
In-Reply-To: <20110918.223744.2195272571175354579.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/19/2011 04:37 AM, David Miller wrote:
>> D-SACK is allowed to reside below snd_una. But the corresponding check
>> in tcp_is_sackblock_valid() is the exact opposite. It looks like a typo.
>>
>> Signed-off-by: Zheng Yan<zheng.z.yan@intel.com>
>> Acked-by: Eric Dumazet<eric.dumazet@gmail.com>
> Applied, thanks.

Dave,

Have you also queued it up for stable as per Eric's remark that this was 
introduced in 2.6.24?

Sorry if this is implied in your workflow.

Thanks, Jan
