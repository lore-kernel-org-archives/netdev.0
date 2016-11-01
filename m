From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 0/7] stmmac: dwmac-sti refactor+cleanup
Date: Tue, 01 Nov 2016 11:56:34 -0400 (EDT)
Message-ID: <20161101.115634.415403364673533569.davem@davemloft.net>
References: <20161030200507.851-1-manabian@gmail.com>
        <20161031.154726.460941249322981922.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, alexandre.torgue@st.com,
        netdev@vger.kernel.org
To: manabian@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:46952 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750720AbcKAP4f (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 1 Nov 2016 11:56:35 -0400
In-Reply-To: <20161031.154726.460941249322981922.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Mon, 31 Oct 2016 15:47:26 -0400 (EDT)

> From: Joachim Eastwood <manabian@gmail.com>
> Date: Sun, 30 Oct 2016 21:05:00 +0100
> 
>> This patch set aims to remove the init/exit callbacks from the 
>> dwmac-sti driver and instead use standard PM callbacks. Doing this
>> will also allow us to cleanup the driver.
>> 
>> Eventually the init/exit callbacks will be deprecated and removed
>> from all drivers dwmac-* except for dwmac-generic. Drivers will be
>> refactored to use standard PM and remove callbacks.
>> 
>> Note that this patch set has only been test compiled and no functional
>> change is intended.
> 
> I would really like to see some review and testing before applying this
> series.

Ping?
