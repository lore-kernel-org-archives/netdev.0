From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] tg3: fix build-time dependency with
 IS_DEPENDENCY_SATISFIED()
Date: Mon, 01 Oct 2012 17:45:35 -0400 (EDT)
Message-ID: <20121001.174535.32880983714519058.davem@davemloft.net>
References: <1349094080-769-1-git-send-email-anisse@astier.eu>
	<1349094080-769-2-git-send-email-anisse@astier.eu>
	<20121001161059.GA27396@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: anisse@astier.eu, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, mmarek@suse.cz,
	torvalds@linux-foundation.org, mchan@broadcom.com,
	mcarlson@broadcom.com
To: paul.gortmaker@windriver.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20121001161059.GA27396@windriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Paul Gortmaker <paul.gortmaker@windriver.com>
Date: Mon, 1 Oct 2012 12:10:59 -0400

> From e7c432cf5eb44b188c1aa2b188877c42300de8b9 Mon Sep 17 00:00:00 2001
> From: Paul Gortmaker <paul.gortmaker@windriver.com>
> Date: Mon, 1 Oct 2012 11:43:49 -0400
> Subject: [PATCH] tg3: unconditionally select HWMON support when tg3 is
>  enabled.
> 
> There is the seldom used corner case where HWMON=m at the same
> time as TIGON3=y (typically randconfigs) which will cause a link
> fail like:
> 
> drivers/built-in.o: In function `tg3_close':
> tg3.c:(.text+0x16bd86): undefined reference to `hwmon_device_unregister'
> drivers/built-in.o: In function `tg3_hwmon_open':
> tg3.c:(.text+0x16fc4b): undefined reference to `hwmon_device_register'
> make[1]: *** [vmlinux] Error 1
> 
> Fix it as suggested by DaveM[1] by having the Kconfig logic simply
> select HWMON when TIGON3 is selected.  This gets rid of all the
> extra IS_ENABLED ifdeffery in tg3.c as a side benefit.
> 
> [1] http://marc.info/?l=linux-netdev&m=134250573718151&w=2
> 
> Cc: Michael Chan <mchan@broadcom.com>
> Reported-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
> Reported-by: Anisse Astier <anisse@astier.eu>
> Suggested-by: David S. Miller <davem@davemloft.net>
> Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>

Applied, thanks.
