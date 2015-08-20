From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/3] qeth: Convert use of __constant_htons to
 htons
Date: Thu, 20 Aug 2015 13:56:36 -0700 (PDT)
Message-ID: <20150820.135636.273361607490862959.davem@davemloft.net>
References: <1440078822.685.11.camel@BR9GV9YG.de.ibm.com>
	<20150820.105810.2093197275802835044.davem@davemloft.net>
	<CAK-LDbKJwjgOSgva-4yUay-wOXqAtS=tn-soE9H5xvMQMV56wA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ubraun@linux.vnet.ibm.com, David.Laight@aculab.com,
	schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com,
	netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	ursula.braun@de.ibm.com
To: vthakkar1994@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57127 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752107AbbHTU4j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Aug 2015 16:56:39 -0400
In-Reply-To: <CAK-LDbKJwjgOSgva-4yUay-wOXqAtS=tn-soE9H5xvMQMV56wA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vaishali Thakkar <vthakkar1994@gmail.com>
Date: Fri, 21 Aug 2015 00:28:59 +0530

> On Thu, Aug 20, 2015 at 11:28 PM, David Miller <davem@davemloft.net> wrote:
>> From: Ursula Braun <ubraun@linux.vnet.ibm.com>
>> Date: Thu, 20 Aug 2015 15:53:42 +0200
>>
>>> qeth is an s390-driver, and s390 is a big-endian architecture. Thus
>>> arguments valid for little-endian do not apply to qeth-code.
>>
>> You can not throw out generally good tree-wide conventions just because
>> it happens to work on your platform.
>>
>> In fact, I would be really thrilled if some of this code could be compiled
>> on other platforms via COMPILE_TEST or similar, especially the socket code
>> and drivers.
> 
> I have test-compiled this patch on little-endian architecture. I used
> this script for cross compilation:
> https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross

If you cross compiled "from" a little endian architecture, that doesn't
mean anything.

What matters is if you compiled this code "targetting" a little-endian
architecture which currently is not possible.
