From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: Re: [RFC(v2) net-next 13/13] ipv6: Complete neighbour entry removal
 from dst_entry.
Date: Wed, 16 Jan 2013 23:04:35 +0900
Message-ID: <50F6B373.5040106@linux-ipv6.org>
References: <50F587ED.5070602@linux-ipv6.org> <50F6521F.4020706@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:42638 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752850Ab3APOEg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jan 2013 09:04:36 -0500
In-Reply-To: <50F6521F.4020706@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cong Wang wrote:
> On 01/16/2013 12:46 AM, YOSHIFUJI Hideaki wrote:
>> +#if 0
>>   		if (rt->n && rt->n->dev == dev) {
>>   			rt->n->dev = loopback_dev;
>>   			dev_hold(loopback_dev);
>>   			dev_put(dev);
>>   		}
>> +#endif
> 
> Why commenting this out instead of removing it? As rt->n is totally
> removed, how possible could we reuse this code in future?

I have confirmed that this dev_put()/dev_hold() operation are really
for neigh->dev, which has refcnt for dev, so I agree.

(This is why I need to revisit refcnt 

--yoshfuji
