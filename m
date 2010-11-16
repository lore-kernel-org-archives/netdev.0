From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6 v2] macvlan: lockless tx path
Date: Tue, 16 Nov 2010 10:59:31 -0800 (PST)
Message-ID: <20101116.105931.28828795.davem@davemloft.net>
References: <1289411027.2860.248.camel@edumazet-laptop>
	<1289459644.17691.1011.camel@edumazet-laptop>
	<4CDCF8C3.6010007@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	greearb@candelatech.com, bhutchings@solarflare.com
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:32926
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757229Ab0KPS7H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Nov 2010 13:59:07 -0500
In-Reply-To: <4CDCF8C3.6010007@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>
Date: Fri, 12 Nov 2010 09:20:19 +0100

> On 11.11.2010 08:14, Eric Dumazet wrote:
>> macvlan is a stacked device, like tunnels. We should use the lockless
>> mechanism we are using in tunnels and loopback.
>> 
>> This patch completely removes locking in TX path.
>> 
>> tx stat counters are added into existing percpu stat structure, renamed
>> from rx_stats to pcpu_stats.
>> 
>> Note : this reverts commit 2c11455321f37 (macvlan: add multiqueue
>> capability)
>> 
>> Note : rx_errors converted to a 32bit counter, like tx_dropped, since
>> they dont need 64bit range.
>> 
>> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
>> Cc: Patrick McHardy <kaber@trash.net>
>> Cc: Ben Greear <greearb@candelatech.com>
>> Cc: Ben Hutchings <bhutchings@solarflare.com>
>> ---
>> V2: correct kerneldoc
>>     u32 for tx_dropped and rx_errors
> 
> Looks good to me.
> 
> Acked-by: Patrick McHardy <kaber@trash.net>

Applied, thanks everyone.
