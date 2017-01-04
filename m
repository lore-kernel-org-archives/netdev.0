From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] LiquidIO VF: s/select/imply/ for PTP_1588_CLOCK
Date: Wed, 04 Jan 2017 13:27:40 -0500 (EST)
Message-ID: <20170104.132740.2188422711538684674.davem@davemloft.net>
References: <20170103101105.GA24780@localhost.localdomain>
        <alpine.LFD.2.20.1701031331450.21662@knanqh.ubzr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: richardcochran@gmail.com, rvatsavayi@caviumnetworks.com,
        netdev@vger.kernel.org
To: nicolas.pitre@linaro.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:59002 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S936806AbdADS1m (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 4 Jan 2017 13:27:42 -0500
In-Reply-To: <alpine.LFD.2.20.1701031331450.21662@knanqh.ubzr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Pitre <nicolas.pitre@linaro.org>
Date: Tue, 3 Jan 2017 13:57:00 -0500 (EST)

> Fix a minor fallout from the merge of the timers and the networking 
> trees. The following error may result if the PTP_1588_CLOCK 
> prerequisites are not available:
> 
> drivers/built-in.o: In function `ptp_clock_unregister':
> (.text+0x40e0a5): undefined reference to `pps_unregister_source'
> drivers/built-in.o: In function `ptp_clock_unregister':
> (.text+0x40e0cc): undefined reference to `posix_clock_unregister'
> drivers/built-in.o: In function `ptp_clock_event':
> (.text+0x40e249): undefined reference to `pps_event'
> drivers/built-in.o: In function `ptp_clock_register':
> (.text+0x40e5e1): undefined reference to `pps_register_source'
> drivers/built-in.o: In function `ptp_clock_register':
> (.text+0x40e62c): undefined reference to `posix_clock_register'
> drivers/built-in.o: In function `ptp_clock_register':
> (.text+0x40e68d): undefined reference to `pps_unregister_source'
> 
> Signed-off-by: Nicolas Pitre <nico@linaro.org>

Applied, thanks.
