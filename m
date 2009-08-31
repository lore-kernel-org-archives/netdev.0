From: Rene Mayrhofer <rene.mayrhofer@gibraltar.at>
Subject: Re: [PATCH] sky2: Don't try to turn led off in sky2_down()
Date: Mon, 31 Aug 2009 11:48:03 +0200
Message-ID: <200908311148.03849.rene.mayrhofer@gibraltar.at>
References: <4A9928C9.7000907@ring3k.org>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org, Richard Leitner <leitner@esys.at>
To: Mike McCormack <mikem@ring3k.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from jupiter.gibraltar.at ([80.120.3.98]:42090 "EHLO
	mail1.gibraltar.at" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751161AbZHaJsQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Aug 2009 05:48:16 -0400
In-Reply-To: <4A9928C9.7000907@ring3k.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Mika and Stephen,

Am Samstag, 29. August 2009 15:10:33 schrieb Mike McCormack:
> There are a few problems with the following line of code in sky2_down()
>
>      sky2_write16(hw, B0_Y2LED, LED_STAT_OFF);
>
>  * It doesn't specify which port's LED to turn off.
>  * We don't turn send LED_STAT_ON on in sky2_up()
>  * B0_LED is 0x0006 in the vendor driver, but 0x0005 in sky2.
>    B0_LED is right next to B0_POWER_CTRL, so this is possibly
>    accounts for the device being accidently powered down as
>    reported by Rene Mayrhofer.
>
> Signed-off-by: Mike McCormack <mikem@ring3k.org>

I tried the current net-next version with this patch, and a network restart 
still leads to a system reset. Is this patch aimed at net-next or the vanilla 
2.6.30.5 version?

I assume the updated 2 patches would not make any difference, right?

best regards,
Rene

-- 
-------------------------------------------------
Gibraltar firewall       http://www.gibraltar.at/
