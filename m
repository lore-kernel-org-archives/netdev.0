From: matthieu castet <castet.matthieu@free.fr>
Subject: Re: [PATCH] bc47xx : export ssb_watchdog_timer_set
Date: Thu, 21 May 2009 12:39:20 +0200
Message-ID: <4A152F58.5040905@free.fr>
References: <4A11DCBF.9000700@free.fr> <200905191522.40519.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-mips@linux-mips.org, netdev@vger.kernel.org
To: Michael Buesch <mb@bu3sch.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1-g21.free.fr ([212.27.42.1]:37570 "EHLO smtp1-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752321AbZEUKj3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 May 2009 06:39:29 -0400
In-Reply-To: <200905191522.40519.mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Michael Buesch wrote:
> On Tuesday 19 May 2009 00:10:07 matthieu castet wrote:
>> Hi,
>>
>> this patch export ssb_watchdog_timer_set to allow to use it in a Linux 
>> watchdog driver.
>>
>>
>> Signed-off-by: Matthieu CASTET <castet.matthieu@free.fr>
> 
> Well, you need to be careful. The watchdog is also used for system reboot.
> Make sure to disable the watchdog driver when the bcm47xx system code wants
> to use it.
> 
It shouldn't be a problem : the system code always disable irq before 
using watchdog to reboot/halt (unless I miss other watchdog usage).

Matthieu
