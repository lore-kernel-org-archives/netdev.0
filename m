From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] ARM: dts: at91: VInCo: fix phy reset gpio flag
Date: Tue, 26 Apr 2016 21:25:13 +0300
Message-ID: <571FB289.40807@cogentembedded.com>
References: <570BF481.9070903@cogentembedded.com>
 <1461666272-10107-1-git-send-email-nicolas.ferre@atmel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	Gregory Clement <gregory.clement@free-electrons.com>,
	Alexandre Belloni <alexandre.belloni@free-electrons.com>,
	netdev@vger.kernel.org, Andrew Lunn <andrew@lunn.ch>,
	David Miller <davem@davemloft.net>
To: Nicolas Ferre <nicolas.ferre@atmel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f48.google.com ([209.85.215.48]:35762 "EHLO
	mail-lf0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753497AbcDZSZR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Apr 2016 14:25:17 -0400
Received: by mail-lf0-f48.google.com with SMTP id c126so28825147lfb.2
        for <netdev@vger.kernel.org>; Tue, 26 Apr 2016 11:25:16 -0700 (PDT)
In-Reply-To: <1461666272-10107-1-git-send-email-nicolas.ferre@atmel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 04/26/2016 01:24 PM, Nicolas Ferre wrote:

> Fix gpio active flag for the phy reset-gpios property. The line is
> active low instead of active high.
> Actually, this flags was never used by the macb driver.
>
> Reported-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
> Cc: Andrew Lunn <andrew@lunn.ch>
> Cc: David Miller <davem@davemloft.net>
> Signed-off-by: Nicolas Ferre <nicolas.ferre@atmel.com>
> ---
> Hi,
>
> Thanks for having reported this bug to me.

    And thank you for beating me to it and doing the patch. I'm still busy 
with other stuff. :-(

> I hope that we will be able to move forward for changing the phy
> reset code in the macb driver.

    I meant to delete it entirely.

> I plan to queue this patch through arm-soc for 4.7.

    Hm, that way we get that board broken if my phylib/macb patches get merged 
before your patch. Perhaps it would be better to merge this patch thru DaveM's 
tree (before my patches) to keep the kernel bisectable?

> Thanks, best regards,
>    Nicolas

MBR, Sergei
