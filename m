From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next] openvswitch: Use kmem_cache_free() instead of
 kfree()
Date: Thu, 09 Jan 2014 14:27:10 -0500 (EST)
Message-ID: <20140109.142710.1451122886569606171.davem@davemloft.net>
References: <CAPgLHd_jaxf4jsvUzBhE_RFioHgZzvmWhA=d_J5phUOhBGy49g@mail.gmail.com>
	<CAEP_g=9HVB0UkajKesyC8Dkj=0ts3kExbhhHKj2wrjx9RymEog@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: weiyj.lk@gmail.com, pshelar@nicira.com,
	yongjun_wei@trendmicro.com.cn, dev@openvswitch.org,
	netdev@vger.kernel.org
To: jesse@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33140 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751137AbaAIT1Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jan 2014 14:27:16 -0500
In-Reply-To: <CAEP_g=9HVB0UkajKesyC8Dkj=0ts3kExbhhHKj2wrjx9RymEog@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Gross <jesse@nicira.com>
Date: Wed, 8 Jan 2014 09:17:11 -0500

> On Wed, Jan 8, 2014 at 5:13 AM, Wei Yongjun <weiyj.lk@gmail.com> wrote:
>> From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
>>
>> memory allocated by kmem_cache_alloc() should be freed using
>> kmem_cache_free(), not kfree().
>>
>> Fixes: e298e5057006 ('openvswitch: Per cpu flow stats.')
>> Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
> 
> Good catch, thanks.
> 
> I'll let David pick this up directly since I just flushed my patch queue.
> 
> Acked-by: Jesse Gross <jesse@nicira.com>

Applied, thanks.
