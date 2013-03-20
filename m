From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] genetlink: trigger BUG_ON if a group name is too
 long
Date: Wed, 20 Mar 2013 18:10:05 -0400 (EDT)
Message-ID: <20130320.181005.1507999596274688798.davem@davemloft.net>
References: <CAE9FiQXgv8EZGQ142NyV5D1M2+HKSaSoafNzdXY2SBO+iQjdGw@mail.gmail.com>
	<20130320.171305.1359445944793447383.davem@davemloft.net>
	<CAE9FiQX+9NXfVO9P1ZELYjA+D35Tt7r0ngsGZfW9VaU1Q0WJvQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rui.zhang@intel.com, yamato@redhat.com, netdev@vger.kernel.org
To: yinghai@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34812 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752123Ab3CTWKH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Mar 2013 18:10:07 -0400
In-Reply-To: <CAE9FiQX+9NXfVO9P1ZELYjA+D35Tt7r0ngsGZfW9VaU1Q0WJvQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yinghai Lu <yinghai@kernel.org>
Date: Wed, 20 Mar 2013 14:16:22 -0700

> On Wed, Mar 20, 2013 at 2:13 PM, David Miller <davem@davemloft.net> wrote:
>>>
>>> [    6.047966] ------------[ cut here ]------------
>>> [    6.048944] kernel BUG at net/netlink/genetlink.c:145!
>>
>> For the second time, we know about this bug.
>>
>> His second patch fixes the themal layer bug.
>>
>> But I told him to send it to the thermal maintainers so that they
>> can integrate it.
>>
>> Why are you posting what we know already over and over?
> 
> so bisecting will be broken?

Good point, so I'll apply the thermal patch to my tree to minimize
the failure range.

Thanks.
