From: Mike McCormack <mikem@ring3k.org>
Subject: Re: [PATCH] sky2: Don't try to turn led off in sky2_down()
Date: Sun, 30 Aug 2009 09:37:54 +0900
Message-ID: <4A99C9E2.30001@ring3k.org>
References: <4A9928C9.7000907@ring3k.org> <20090829105727.6281202e@s6510>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Rene Mayrhofer <rene.mayrhofer@gibraltar.at>,
	Richard Leitner <leitner@esys.at>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f204.google.com ([209.85.223.204]:53762 "EHLO
	mail-iw0-f204.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752967AbZH3Alr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Aug 2009 20:41:47 -0400
Received: by iwn42 with SMTP id 42so1374099iwn.33
        for <netdev@vger.kernel.org>; Sat, 29 Aug 2009 17:41:49 -0700 (PDT)
In-Reply-To: <20090829105727.6281202e@s6510>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger wrote:
> On Sat, 29 Aug 2009 22:10:33 +0900
> Mike McCormack <mikem@ring3k.org> wrote:
> 
>> There are a few problems with the following line of code in sky2_down()
>>
>>      sky2_write16(hw, B0_Y2LED, LED_STAT_OFF);
>>
>>  * It doesn't specify which port's LED to turn off.
>>  * We don't turn send LED_STAT_ON on in sky2_up()
>>  * B0_LED is 0x0006 in the vendor driver, but 0x0005 in sky2.
>>    B0_LED is right next to B0_POWER_CTRL, so this is possibly
>>    accounts for the device being accidently powered down as
>>    reported by Rene Mayrhofer.
> 
> I would rather just change the definition of B0_LED to the correct value.

How does that address the first problem?  If there are two ports, which port's LED are we turning off?

thanks,

Mike
