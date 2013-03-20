From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] genetlink: trigger BUG_ON if a group name is too
 long
Date: Wed, 20 Mar 2013 17:13:05 -0400 (EDT)
Message-ID: <20130320.171305.1359445944793447383.davem@davemloft.net>
References: <CAE9FiQURBR=iTbksUzb_i23g6N56Acg2J8bab9zr1UcwT5tWzA@mail.gmail.com>
	<20130320.170511.343122156621608721.davem@davemloft.net>
	<CAE9FiQXgv8EZGQ142NyV5D1M2+HKSaSoafNzdXY2SBO+iQjdGw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rui.zhang@intel.com, yamato@redhat.com, netdev@vger.kernel.org
To: yinghai@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34150 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750758Ab3CTVNH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Mar 2013 17:13:07 -0400
In-Reply-To: <CAE9FiQXgv8EZGQ142NyV5D1M2+HKSaSoafNzdXY2SBO+iQjdGw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yinghai Lu <yinghai@kernel.org>
Date: Wed, 20 Mar 2013 14:06:06 -0700

> On Wed, Mar 20, 2013 at 2:05 PM, David Miller <davem@davemloft.net> wrote:
>> From: Yinghai Lu <yinghai@kernel.org>
>> Date: Wed, 20 Mar 2013 14:01:09 -0700
>>
>>> On Wed, Mar 20, 2013 at 9:07 AM, David Miller <davem@davemloft.net> wrote:
>>>> From: Masatake YAMATO <yamato@redhat.com>
>>>> Date: Tue, 19 Mar 2013 20:47:27 +0900
>>>>
>>>>> Trigger BUG_ON if a group name is longer than GENL_NAMSIZ.
>>>>>
>>>>> Signed-off-by: Masatake YAMATO <yamato@redhat.com>
>>>>
>>>> Applied, thanks.
>>>
>>> catch one in
>>
>> Seriously?
>>
>> That's what his second patch in this series fixes, we know about it
>> already.
> 
> [    6.047966] ------------[ cut here ]------------
> [    6.048944] kernel BUG at net/netlink/genetlink.c:145!

For the second time, we know about this bug.

His second patch fixes the themal layer bug.

But I told him to send it to the thermal maintainers so that they
can integrate it.

Why are you posting what we know already over and over?
