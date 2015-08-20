From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/3] qeth: Convert use of __constant_htons to
 htons
Date: Thu, 20 Aug 2015 10:58:10 -0700 (PDT)
Message-ID: <20150820.105810.2093197275802835044.davem@davemloft.net>
References: <1440071036.685.7.camel@BR9GV9YG.de.ibm.com>
	<063D6719AE5E284EB5DD2968C1650D6D1CB8054E@AcuExch.aculab.com>
	<1440078822.685.11.camel@BR9GV9YG.de.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: David.Laight@ACULAB.COM, schwidefsky@de.ibm.com,
	heiko.carstens@de.ibm.com, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org, ursula.braun@de.ibm.com,
	vthakkar1994@gmail.com
To: ubraun@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56160 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751239AbbHTR6M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Aug 2015 13:58:12 -0400
In-Reply-To: <1440078822.685.11.camel@BR9GV9YG.de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Date: Thu, 20 Aug 2015 15:53:42 +0200

> qeth is an s390-driver, and s390 is a big-endian architecture. Thus
> arguments valid for little-endian do not apply to qeth-code.

You can not throw out generally good tree-wide conventions just because
it happens to work on your platform.

In fact, I would be really thrilled if some of this code could be compiled
on other platforms via COMPILE_TEST or similar, especially the socket code
and drivers.
