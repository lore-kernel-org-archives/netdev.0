From: Jiri Slaby <jslaby@suse.cz>
Subject: Re: v3.12-stable-queue build errors
Date: Mon, 27 Apr 2015 20:00:06 +0200
Message-ID: <553E7926.7040108@suse.cz>
References: <20150425141609.GA1147@roeck-us.net>	<553DF71E.7060409@suse.cz>	<87fv7lk2i0.fsf@x220.int.ebiederm.org> <20150427.122528.2203423133753350979.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux@roeck-us.net, stable@vger.kernel.org
To: David Miller <davem@davemloft.net>, ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f170.google.com ([209.85.212.170]:33934 "EHLO
	mail-wi0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932949AbbD0SAK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Apr 2015 14:00:10 -0400
In-Reply-To: <20150427.122528.2203423133753350979.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/27/2015, 06:25 PM, David Miller wrote:
> From: ebiederm@xmission.com (Eric W. Biederman)
> Date: Mon, 27 Apr 2015 10:35:51 -0500
> 
>> Jiri Slaby <jslaby@suse.cz> writes:
>>
>>> On 04/25/2015, 04:16 PM, Guenter Roeck wrote:
>>>> Several powerpc build fail with:
>>>>
>>>> drivers/net/ethernet/freescale/gianfar.c: In function 'gfar_start_xmit':
>>>> drivers/net/ethernet/freescale/gianfar.c:2146:3: error: implicit declaration of
>>>> function 'dev_consume_skb_any' [-Werror=implicit-function-declaration]
>>>>    dev_consume_skb_any(skb);
>>>>
>>>> dev_consume_skb_any() does not exist in 3.12.
>>>>
>>>> Introduced by 'gianfar: Carefully free skbs in functions called by netpoll'.
>>>
>>> Eric, David,
>>>
>>> what action should I take here?
>>>
>>> 1) take also:
>>> commit e6247027e5173c00efb2084d688d06ff835bc3b0
>>> Author: Eric Dumazet <edumazet@google.com>
>>> Date:   Thu Dec 5 04:45:08 2013 -0800
>>>
>>>     net: introduce dev_consume_skb_any()
>>>
>>>
>>> 2) drop 'gianfar: Carefully free skbs in functions called by netpoll'
>>> from stable-3.12
>>
>> This is probably the most reasonable.   KISS.
> 
> Yeah just drop the patch.
> 
> I didn't even want to submit this series in the first place but
> people kept poking me endlessly about it.

Now dropped. Thanks.

-- 
js
suse labs
