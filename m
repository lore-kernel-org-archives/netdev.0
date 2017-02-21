From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3 0/4] net: mvneta: improve rx/tx performance
Date: Tue, 21 Feb 2017 11:16:02 -0500 (EST)
Message-ID: <20170221.111602.860315087619854954.davem@davemloft.net>
References: <20170220125344.3555-1-jszhang@marvell.com>
        <877f4laqog.fsf@free-electrons.com>
        <20170221123726.2db7db19@xhacker>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gregory.clement@free-electrons.com,
        thomas.petazzoni@free-electrons.com, arnd@arndb.de,
        mw@semihalf.com, linux-arm-kernel@lists.infradead.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: jszhang@marvell.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:54332 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753578AbdBUQQF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 21 Feb 2017 11:16:05 -0500
In-Reply-To: <20170221123726.2db7db19@xhacker>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jisheng Zhang <jszhang@marvell.com>
Date: Tue, 21 Feb 2017 12:37:40 +0800

> Thanks for your review.
> 
> The measurement is simple: record how much time we spent in mvneta_rx_swbm()
> for receiving 1GB data, something as below:

Please use a standard tool for measuring performance, rather than profiling
the driver and trying to derive numbers that way.
