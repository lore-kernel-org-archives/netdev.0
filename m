From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH] LiquidIO VF: s/select/imply/ for PTP_1588_CLOCK
Date: Tue, 3 Jan 2017 20:24:12 +0100
Message-ID: <20170103192412.GA23297@netboy>
References: <20170103101105.GA24780@localhost.localdomain>
 <alpine.LFD.2.20.1701031331450.21662@knanqh.ubzr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Nicolas Pitre <nicolas.pitre@linaro.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wj0-f196.google.com ([209.85.210.196]:34200 "EHLO
        mail-wj0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934089AbdACTYR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 3 Jan 2017 14:24:17 -0500
Received: by mail-wj0-f196.google.com with SMTP id qs7so35377791wjc.1
        for <netdev@vger.kernel.org>; Tue, 03 Jan 2017 11:24:17 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.20.1701031331450.21662@knanqh.ubzr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 03, 2017 at 01:57:00PM -0500, Nicolas Pitre wrote:
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

Thanks for following up on this.

Acked-by: Richard Cochran <richardcochran@gmail.com>
