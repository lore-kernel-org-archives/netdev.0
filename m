From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] sky2: Don't try to turn led off in sky2_down()
Date: Sat, 29 Aug 2009 10:57:27 -0700
Message-ID: <20090829105727.6281202e@s6510>
References: <4A9928C9.7000907@ring3k.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org,
	Rene Mayrhofer <rene.mayrhofer@gibraltar.at>,
	Richard Leitner <leitner@esys.at>
To: Mike McCormack <mikem@ring3k.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:34435 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752012AbZH2R5c (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 29 Aug 2009 13:57:32 -0400
In-Reply-To: <4A9928C9.7000907@ring3k.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 29 Aug 2009 22:10:33 +0900
Mike McCormack <mikem@ring3k.org> wrote:

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

I would rather just change the definition of B0_LED to the correct value.
