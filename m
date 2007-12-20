From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: [PATCH] e1000e: Use deferrable timer for watchdog
Date: Thu, 20 Dec 2007 09:05:07 -0800
Message-ID: <476AA0C3.2080503@intel.com>
References: <Pine.LNX.4.64.0712182046560.3616@mini.warudkars.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	akpm@linux-foundation.org
To: parag.warudkar@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:9190 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759991AbXLTR0y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Dec 2007 12:26:54 -0500
In-Reply-To: <Pine.LNX.4.64.0712182046560.3616@mini.warudkars.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Parag Warudkar wrote:
> 
> Reduce wakeups from idle per second.
> 
> Signed-off-by: Parag Warudkar <parag.warudkar@gmail.com>
> 
> --- linux-2.6/drivers/net/e1000e/netdev.c    2007-12-07
> 10:04:39.000000000 -0500
> +++ linux-2.6-work/drivers/net/e1000e/netdev.c    2007-12-18
> 20:45:59.000000000 -0500
> @@ -3899,7 +3899,7 @@
>          goto err_eeprom;
>      }
> 
> -    init_timer(&adapter->watchdog_timer);
> +    init_timer_deferrable(&adapter->watchdog_timer);
>      adapter->watchdog_timer.function = &e1000_watchdog;
>      adapter->watchdog_timer.data = (unsigned long) adapter;


I can't even apply this patch and the e1000 one... not only is it whitespace
damaged it is also not properly formatted as patch at all. If you want me to take
these patches seriously, then please fix the formatting issues.

Auke
