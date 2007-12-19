From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: [PATCH] e1000e: Use deferrable timer for watchdog
Date: Wed, 19 Dec 2007 11:04:10 -0800
Message-ID: <47696B2A.1020301@intel.com>
References: <Pine.LNX.4.64.0712182046560.3616@mini.warudkars.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	akpm@linux-foundation.org
To: parag.warudkar@gmail.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754947AbXLSTFL@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.64.0712182046560.3616@mini.warudkars.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

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
> 


see my reply to "Re: [PATCH] e1000: Use deferrable timer for watchdog" - IOW no,
we don't want this

Auke
