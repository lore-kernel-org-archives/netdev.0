From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] liquidio: fix format truncation warning
 reported by gcc 7.1.1
Date: Sat, 30 Sep 2017 05:29:02 +0100 (WEST)
Message-ID: <20170930.052902.1191894186277479084.davem@davemloft.net>
References: <20170926184827.GA3512@felix-thinkpad.cavium.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, raghu.vatsavayi@cavium.com,
        derek.chickles@cavium.com, satananda.burla@cavium.com
To: felix.manlunas@cavium.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:40028 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750960AbdI3E3E (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 30 Sep 2017 00:29:04 -0400
In-Reply-To: <20170926184827.GA3512@felix-thinkpad.cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Felix Manlunas <felix.manlunas@cavium.com>
Date: Tue, 26 Sep 2017 11:48:27 -0700

> From: Satanand Burla <satananda.burla@cavium.com>
> 
> gcc 7.1.1 with -Wformat-truncation reports these warnings:
> 
> drivers/net/ethernet/cavium/liquidio/lio_core.c: In function `octeon_setup_interrupt':
> drivers/net/ethernet/cavium/liquidio/lio_core.c:1003:41: warning: `%u' directive output may be truncated writing between 1 and 10 bytes into a region of size between 0 and 13 [-Wformat-truncation=]
>        INTRNAMSIZ, "LiquidIO%u-pf%u-rxtx-%u",
>                                          ^~

Please just increase INTRNAMSIZ as needed.

Thanks.
