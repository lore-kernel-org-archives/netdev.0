From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH net-next 1/1] ptp: gianfar: Use high resolution frequency
 method.
Date: Wed, 23 Nov 2016 21:23:43 +0100
Message-ID: <20161123202343.GA2845@localhost.localdomain>
References: <20161123201104.9706-1-ulrik.debie-os@e2big.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Ulrik De Bie <ulrik.debie-os@e2big.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wj0-f195.google.com ([209.85.210.195]:33748 "EHLO
        mail-wj0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933402AbcKWUXs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 23 Nov 2016 15:23:48 -0500
Received: by mail-wj0-f195.google.com with SMTP id kp2so1841129wjc.0
        for <netdev@vger.kernel.org>; Wed, 23 Nov 2016 12:23:47 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20161123201104.9706-1-ulrik.debie-os@e2big.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 23, 2016 at 09:11:04PM +0100, Ulrik De Bie wrote:
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

Acked-by: Richard Cochran <richardcochran@gmail.com>
