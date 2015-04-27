From: David Miller <davem@davemloft.net>
Subject: Re: v3.12-stable-queue build errors
Date: Mon, 27 Apr 2015 12:25:28 -0400 (EDT)
Message-ID: <20150427.122528.2203423133753350979.davem@davemloft.net>
References: <20150425141609.GA1147@roeck-us.net>
	<553DF71E.7060409@suse.cz>
	<87fv7lk2i0.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jslaby@suse.cz, netdev@vger.kernel.org, linux@roeck-us.net,
	stable@vger.kernel.org
To: ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55586 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753224AbbD0QZb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Apr 2015 12:25:31 -0400
In-Reply-To: <87fv7lk2i0.fsf@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Mon, 27 Apr 2015 10:35:51 -0500

> Jiri Slaby <jslaby@suse.cz> writes:
> 
>> On 04/25/2015, 04:16 PM, Guenter Roeck wrote:
>>> Several powerpc build fail with:
>>> 
>>> drivers/net/ethernet/freescale/gianfar.c: In function 'gfar_start_xmit':
>>> drivers/net/ethernet/freescale/gianfar.c:2146:3: error: implicit declaration of
>>> function 'dev_consume_skb_any' [-Werror=implicit-function-declaration]
>>>    dev_consume_skb_any(skb);
>>> 
>>> dev_consume_skb_any() does not exist in 3.12.
>>> 
>>> Introduced by 'gianfar: Carefully free skbs in functions called by netpoll'.
>>
>> Eric, David,
>>
>> what action should I take here?
>>
>> 1) take also:
>> commit e6247027e5173c00efb2084d688d06ff835bc3b0
>> Author: Eric Dumazet <edumazet@google.com>
>> Date:   Thu Dec 5 04:45:08 2013 -0800
>>
>>     net: introduce dev_consume_skb_any()
>>
>>
>> 2) drop 'gianfar: Carefully free skbs in functions called by netpoll'
>> from stable-3.12
> 
> This is probably the most reasonable.   KISS.

Yeah just drop the patch.

I didn't even want to submit this series in the first place but
people kept poking me endlessly about it.
