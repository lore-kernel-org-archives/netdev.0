From: Michael Buesch <mb@bu3sch.de>
Subject: Re: [PATCH] bc47xx : export ssb_watchdog_timer_set
Date: Tue, 19 May 2009 15:22:40 +0200
Message-ID: <200905191522.40519.mb@bu3sch.de>
References: <4A11DCBF.9000700@free.fr>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-mips@linux-mips.org, netdev@vger.kernel.org
To: matthieu castet <castet.matthieu@free.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bu3sch.de ([62.75.166.246]:51661 "EHLO vs166246.vserver.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751873AbZESNX5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 May 2009 09:23:57 -0400
In-Reply-To: <4A11DCBF.9000700@free.fr>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 19 May 2009 00:10:07 matthieu castet wrote:
> Hi,
> 
> this patch export ssb_watchdog_timer_set to allow to use it in a Linux 
> watchdog driver.
> 
> 
> Signed-off-by: Matthieu CASTET <castet.matthieu@free.fr>

Well, you need to be careful. The watchdog is also used for system reboot.
Make sure to disable the watchdog driver when the bcm47xx system code wants
to use it.

Otherwise, ack. You can submit this to linville@tuxdriver.com.

-- 
Greetings, Michael.
