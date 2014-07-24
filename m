From: Li RongQing <roy.qing.li@gmail.com>
Subject: Re: [PATCH] Revert "usb: gadget: u_ether: synchronize with transmit
 when stopping queue"
Date: Thu, 24 Jul 2014 10:12:40 +0800
Message-ID: <CAJFZqHy+O0ZaNjXm3NGK=XPcmgO-qaH6KUgi7wGX5WVZgPxvmA@mail.gmail.com>
References: <1406166546-21738-1-git-send-email-roy.qing.li@gmail.com>
	<20140724020640.GA20696@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev <netdev@vger.kernel.org>, linux-usb@vger.kernel.org,
	jeff.westfahl@ni.com, Thomas Gleixner <tglx@linutronix.de>
To: Greg KH <greg@kroah.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f43.google.com ([209.85.216.43]:47479 "EHLO
	mail-qa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756120AbaGXCMl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jul 2014 22:12:41 -0400
In-Reply-To: <20140724020640.GA20696@kroah.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 24, 2014 at 10:06 AM, Greg KH <greg@kroah.com> wrote:
>> This reverts commit a9232076374334ca2bc2a448dfde96d38a54349a.
>
> Any reason you didn't cc: the people on that patch, nor the people that
> get_maintainer.pl says to?
>
> Odds are Felipe will miss this one...

jeff.westfahl@ni.com has been Cced, I think Felipe Balbi is maintainer of usb,
and I send it to linux-usb@vger.kernel.org, Felipe Balbi can see it.

Ok, next time, I will use get_maintainer.pl

-Roy


    crash as eth_start_xmit tries to use resources that gether_disconnect is
    freeing. Use netif_tx_lock/unlock around netif_stop_queue to ensure no
    threads are executing during the remainder of gether_disconnect.

    Signed-off-by: Jeff Westfahl <jeff.westfahl@ni.com>
    Tested-by: Jaeden Amero <jaeden.amero@ni.com>
    Signed-off-by: Felipe Balbi <balbi@ti.com>
