From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tg3: Do not call device_set_wakeup_enable() under
 spin_lock_bh
Date: Tue, 26 Oct 2010 11:34:32 -0700 (PDT)
Message-ID: <20101026.113432.68141914.davem@davemloft.net>
References: <201010260101.56128.rjw@sisk.pl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mcarlson@broadcom.com, mchan@broadcom.com, netdev@vger.kernel.org,
	maximlevitsky@gmail.com
To: rjw@sisk.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46738
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933445Ab0JZSeJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Oct 2010 14:34:09 -0400
In-Reply-To: <201010260101.56128.rjw@sisk.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Rafael J. Wysocki" <rjw@sisk.pl>
Date: Tue, 26 Oct 2010 01:01:55 +0200

> From: Rafael J. Wysocki <rjw@sisk.pl>
> 
> The tg3 driver calls device_set_wakeup_enable() under spin_lock_bh,
> which causes a problem to happen after the recent core power
> management changes, because this function can sleep now.  Fix this
> by moving the device_set_wakeup_enable() call out of the
> spin_lock_bh-protected area.
> 
> Reported-by: Maxim Levitsky <maximlevitsky@gmail.com>
> Signed-off-by: Rafael J. Wysocki <rjw@sisk.pl>

Applied, thanks a lot.
