From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RESEND net-next 13/15] smc: receive data from RMBE
Date: Fri, 02 Sep 2016 10:59:33 -0700 (PDT)
Message-ID: <20160902.105933.1696366729773029010.davem@davemloft.net>
References: <653f839a-8098-da62-3437-8b002d929a50@linux.vnet.ibm.com>
        <20160810.104556.1507709019319192063.davem@davemloft.net>
        <7121effc-5f89-ac22-bbab-a8aedebae9fd@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
        schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com,
        utz.bacher@de.ibm.com
To: ubraun@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:54678 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751244AbcIBR7e (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Sep 2016 13:59:34 -0400
In-Reply-To: <7121effc-5f89-ac22-bbab-a8aedebae9fd@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Date: Fri, 2 Sep 2016 15:05:01 +0200

> Understood, I wrongly used xchg() for atomicity. I now realize that I
> would need cursor locking for 32-bit architectures - something I would
> like to defer. Thus I would like to come up with V2 of SMC-R with
> builds restricted to 64-bit architectures only, and thus no usage of
> xchg() anymore.

Please don't restrict the driver build to 64-bit
