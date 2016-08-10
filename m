From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RESEND net-next 13/15] smc: receive data from RMBE
Date: Wed, 10 Aug 2016 10:45:56 -0700 (PDT)
Message-ID: <20160810.104556.1507709019319192063.davem@davemloft.net>
References: <1470737580-43012-14-git-send-email-ubraun@linux.vnet.ibm.com>
	<20160809.143245.2022037008405834176.davem@davemloft.net>
	<653f839a-8098-da62-3437-8b002d929a50@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com,
	utz.bacher@de.ibm.com
To: ubraun@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:40291 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932272AbcHJSCm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Aug 2016 14:02:42 -0400
In-Reply-To: <653f839a-8098-da62-3437-8b002d929a50@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Date: Wed, 10 Aug 2016 15:44:00 +0200

> But there are still usages (and conn->rx_curs_confirmed is one of
> them), where I need an 8-byte cursor field to be read and written
> atomicaly, even though I do not care whether the write operation has
> been beaten or not. But I do care that reading the cursor does not
> return a partially updated cursor. Isn't xchg() a possible solution
> in this case?

Either the cpu supports 64-bit stores or it does not.

xchg() and atomicity have absolutely nothing to do with this.
