From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [4.11 regression] cpsw/netcp: refine cpts dependency
Date: Fri, 28 Apr 2017 15:55:40 -0400 (EDT)
Message-ID: <20170428.155540.1957134198035319334.davem@davemloft.net>
References: <20170428150358.1537030-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: grygorii.strashko@ti.com, nicolas.pitre@linaro.org, w-kwok2@ti.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        tony@atomide.com, linux-omap@vger.kernel.org
To: arnd@arndb.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:58462 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1423598AbdD1Tzn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Apr 2017 15:55:43 -0400
In-Reply-To: <20170428150358.1537030-1-arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arnd Bergmann <arnd@arndb.de>
Date: Fri, 28 Apr 2017 17:03:58 +0200

> Tony Lindgren reports a kernel oops that resulted from my compile-time
> fix on the default config. This shows two problems:
> 
> a) configurations that did not already enable PTP_1588_CLOCK will
>    now miss the cpts driver
> 
> b) when cpts support is disabled, the driver crashes. This is a
>    preexisting problem that we did not notice before my patch.
> 
> While the second problem is still being investigated, this modifies
> the dependencies again, getting us back to the original state, with
> another 'select NET_PTP_CLASSIFY' added in to avoid the original
> link error we got, and the 'depends on POSIX_TIMERS' to hide
> the CPTS support when turning it on would be useless.
> 
> Cc: stable@vger.kernel.org # 4.11 needs this
> Fixes: 07fef3623407 ("cpsw/netcp: cpts depends on posix_timers")
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Applied, thanks Arnd.
