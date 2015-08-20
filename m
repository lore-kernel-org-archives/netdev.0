From: Vaishali Thakkar <vthakkar1994@gmail.com>
Subject: Re: [PATCH net-next 2/3] qeth: Convert use of __constant_htons to htons
Date: Fri, 21 Aug 2015 00:28:59 +0530
Message-ID: <CAK-LDbKJwjgOSgva-4yUay-wOXqAtS=tn-soE9H5xvMQMV56wA@mail.gmail.com>
References: <1440071036.685.7.camel@BR9GV9YG.de.ibm.com>
	<063D6719AE5E284EB5DD2968C1650D6D1CB8054E@AcuExch.aculab.com>
	<1440078822.685.11.camel@BR9GV9YG.de.ibm.com>
	<20150820.105810.2093197275802835044.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Ursula Braun <ubraun@linux.vnet.ibm.com>, David.Laight@aculab.com,
	Martin Schwidefsky <schwidefsky@de.ibm.com>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	Ursula Braun <ursula.braun@de.ibm.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f178.google.com ([209.85.160.178]:36296 "EHLO
	mail-yk0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750986AbbHTS7A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Aug 2015 14:59:00 -0400
In-Reply-To: <20150820.105810.2093197275802835044.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 20, 2015 at 11:28 PM, David Miller <davem@davemloft.net> wrote:
> From: Ursula Braun <ubraun@linux.vnet.ibm.com>
> Date: Thu, 20 Aug 2015 15:53:42 +0200
>
>> qeth is an s390-driver, and s390 is a big-endian architecture. Thus
>> arguments valid for little-endian do not apply to qeth-code.
>
> You can not throw out generally good tree-wide conventions just because
> it happens to work on your platform.
>
> In fact, I would be really thrilled if some of this code could be compiled
> on other platforms via COMPILE_TEST or similar, especially the socket code
> and drivers.

I have test-compiled this patch on little-endian architecture. I used
this script for cross compilation:
https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross

And it worked fine for me.

-- 
Vaishali
