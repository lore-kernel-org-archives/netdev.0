From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] gianfar: Do not call device_set_wakeup_enable() under
 a spinlock
Date: Fri, 12 Nov 2010 14:06:13 -0800 (PST)
Message-ID: <20101112.140613.45885023.davem@davemloft.net>
References: <AANLkTimf_mVrRPEcj8qBbYw1iYHfWdeKUNS3Kk-dfhTT@mail.gmail.com>
	<201011090030.42693.rjw@sisk.pl>
	<201011092254.19550.rjw@sisk.pl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: daniel.blueman@gmail.com, romieu@fr.zoreil.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: rjw@sisk.pl
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201011092254.19550.rjw@sisk.pl>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Rafael J. Wysocki" <rjw@sisk.pl>
Date: Tue, 9 Nov 2010 22:54:19 +0100

> The gianfar driver calls device_set_wakeup_enable() under a spinlock,
> which causes a problem to happen after the recent core power
> management changes, because this function can sleep now.  Fix this
> by moving the device_set_wakeup_enable() call out of the
> spinlock-protected area.
> 
> Signed-off-by: Rafael J. Wysocki <rjw@sisk.pl>

Patch applied, thank you.
