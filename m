From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 13/13] s390/qeth: remove OSN-devices
Date: Wed, 11 Jan 2017 09:05:02 -0500 (EST)
Message-ID: <20170111.090502.567203023670760362.davem@davemloft.net>
References: <20170111115600.4524-1-ubraun@linux.vnet.ibm.com>
        <20170111115600.4524-14-ubraun@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
        schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com,
        stable@vger.kernel.org
To: ubraun@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:49148 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S967171AbdAKOFM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Jan 2017 09:05:12 -0500
In-Reply-To: <20170111115600.4524-14-ubraun@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Date: Wed, 11 Jan 2017 12:56:00 +0100

> CHPID type "OSN" is a device type which had been used by IBM product
> "Communication Controller for Linux". This product has reached end of
> service in March 2016. Thus OSN support can be removed from the qeth
> driver.
> 
> Signed-off-by: Ursula Braun <ubraun@linux.vnet.ibm.com>
> Reviewed-by: Julian Wiedmann <jwi@linux.vnet.ibm.com>
> Reviewed-by: Thomas Richter <tmricht@linux.vnet.ibm.com>

IBM can certainly decide what physical products it wants to support
or not, but this doesn't directly apply to what the Linux kernel
driver supports.

We do not unilaterally remove support for a chip from a driver just
because the vendor decides to stop supporting that chip.  In fact this
is one of the main benefits and value-adds of Linux.

I'm not applying a patch series that removes support for a chipset
for this reason, sorry.
