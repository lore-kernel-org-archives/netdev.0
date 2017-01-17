From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/1] s390/qeth: remove legacy SNA-support
Date: Tue, 17 Jan 2017 10:26:38 -0500 (EST)
Message-ID: <20170117.102638.568359495126686190.davem@davemloft.net>
References: <20170117123951.88480-1-ubraun@linux.vnet.ibm.com>
        <20170117123951.88480-2-ubraun@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
        schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com
To: ubraun@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:37240 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750917AbdAQP0p (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Jan 2017 10:26:45 -0500
In-Reply-To: <20170117123951.88480-2-ubraun@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Date: Tue, 17 Jan 2017 13:39:51 +0100

> The qeth driver supports various operation modes of the underlying
> network interface cards.
> One specific mode (OSN) belonged to a Linux-assisted solution
> that enabled existing IBM mainframe operating systems to continue to run
> the legacy IBM Systems Network Architecture (SNA) protocol.
> Since IBM mainframes ceased to use the SNA protocol and OSN mode
> reached its end of life, this patch removes OSN mode from the qeth
> driver.
> 
> Signed-off-by: Ursula Braun <ubraun@linux.vnet.ibm.com>
> Reviewed-by: Julian Wiedmann <jwi@linux.vnet.ibm.com>
> Reviewed-by: Thomas Richter <tmricht@linux.vnet.ibm.com>
> Reference-ID: NET1609

Please stop trying to remove features from the tree just because a company
decided to end of life a product.  That is not a legitimate justification.

I am not applying this.
