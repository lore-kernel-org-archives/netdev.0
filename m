From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/1] ptp: gianfar: Use high resolution
 frequency method.
Date: Sun, 27 Nov 2016 15:27:04 -0500 (EST)
Message-ID: <20161127.152704.40470444075957548.davem@davemloft.net>
References: <20161123201104.9706-1-ulrik.debie-os@e2big.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, richardcochran@gmail.com
To: ulrik.debie-os@e2big.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:57908 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753608AbcK0U1G (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 27 Nov 2016 15:27:06 -0500
In-Reply-To: <20161123201104.9706-1-ulrik.debie-os@e2big.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ulrik De Bie <ulrik.debie-os@e2big.org>
Date: Wed, 23 Nov 2016 21:11:04 +0100

> This patch depends on commit d8d263541913 ("ptp: Introduce a high
> resolution frequency adjustment method.")
> 
> The gianfar devices offer a frequency resolution of about 0.46 ppb
> (depends on actual value of tmr_add, for the calculation assumed
> 0x80000000). This patch lets users of the device benefit from the increased
> frequency resolution when tuning the clock. Thanks to the rounding the
> maximum error between the requested frequency and the applied frequency
> will then be about 0.23 ppb.
> 
> Tested on a v3.3.8 kernel on a real gianfar device. Verified compilation
> on net-next (currently at v4.9-rc5).
> 
> Signed-off-by: Ulrik De Bie <ulrik.debie-os@e2big.org>

Applied.
