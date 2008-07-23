From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: Re: [PATCH] skge: resolve tx multiqueue bug
Date: Wed, 23 Jul 2008 23:21:14 +0800
Message-ID: <48874C6A.1020604@cn.fujitsu.com>
References: <d4b984a30807210914nd4d0db5yb7b93ca5143ff0d5@mail.gmail.com> <20080721.092027.14394005.davem@davemloft.net> <d4b984a30807220254t1aaf6ac4q874329966511b0c5@mail.gmail.com> <20080723054039.GA2272@gentoox2.trippelsdorf.de> <4886F0C5.7040605@cn.fujitsu.com> <20080723101827.GA2236@gentoox2.trippelsdorf.de> <20080723140347.GA2245@gentoox2.trippelsdorf.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Alessandro Guido <ag@alessandroguido.name>,
	linux-kernel@vger.kernel.org, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org
To: Markus Trippelsdorf <markus@trippelsdorf.de>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:64951 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752232AbYGWPWr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Jul 2008 11:22:47 -0400
In-Reply-To: <20080723140347.GA2245@gentoox2.trippelsdorf.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Markus Trippelsdorf said the following on 2008-7-23 22:03:
> On Wed, Jul 23, 2008 at 12:18:27PM +0200, Markus Trippelsdorf wrote:
>> On Wed, Jul 23, 2008 at 04:50:13PM +0800, Wang Chen wrote:
>>> Markus Trippelsdorf said the following on 2008-7-23 13:40:
>>>> On Tue, Jul 22, 2008 at 11:54:26AM +0200, Alessandro Guido wrote:
>>>>> Got a WARNING this morning (2.6.26-05752-g93ded9b) and I think it's related.
>>>> Same thing here (latest git):
>>>>
>>>> skge eth1: enabling interface
>>>> skge eth1: disabling interface
>>>> ------------[ cut here ]------------
>>>> WARNING: at net/core/dev.c:1344 __netif_schedule+0x24/0x6d()
>>>> Pid: 1904, comm: ip Not tainted 2.6.26-06077-gc010b2f #33
>>>>  [<ffffffff8020b3eb>] system_call_after_swapgs+0x7b/0x80
>> ...
>>>> ---[ end trace 92936ef183e09876 ]---
>>>> skge eth1: enabling interface
>>>> skge eth1: Link is up at 100 Mbps, full duplex, flow control both
>>>>
>>> Markus, please try this.
>>>
>>> - Add netif_start_queue() in ->open()
>>> - netif_carrier_*() is enough, remove netif_*_queue()
>> Unfortunately, your patch does not fix this. I still get the same warning.
>>
> 
> This patch works for me:

Your patch works for me too. So I think it's better than mine. :)

Tested-by: Wang Chen <wangchen@cn.fujitsu.com>

Dave, since Markus and me tested this patch, would you please apply it?



