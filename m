From: Stephan Gatzka <stephan.gatzka@gmail.com>
Subject: Re: [Patch 1/1] net/phy: Add interrupt support for dp83640 phy.
Date: Wed, 05 Dec 2012 20:52:05 +0100
Message-ID: <50BFA5E5.6070307@gmail.com>
References: <1354652498-16573-1-git-send-email-stephan.gatzka@gmail.com> <20121205100544.GA2293@netboy.at.omicron.at>
Reply-To: stephan.gatzka@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:46306 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752131Ab2LETwK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Dec 2012 14:52:10 -0500
Received: by mail-bk0-f46.google.com with SMTP id q16so2374631bkw.19
        for <netdev@vger.kernel.org>; Wed, 05 Dec 2012 11:52:08 -0800 (PST)
In-Reply-To: <20121205100544.GA2293@netboy.at.omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> The patch looks okay to me, but I worry that this might fail on boards
> which have not connected the phyer's PWERDOWN/INTN pin to anything.
> Such designs really need the PHY_POLL working.
> Taking a brief glance at the drivers for two such boards I know of
> (m5234bcc and an IXP), it looks like their MAC drivers set mii_bus irq
> to PHY_POLL, so it might work fine, but this patch still makes me
> nervous that some other board might break.
>
> Maybe this should be a kconfig option?

I don't think so.

Systems using device tree just don't specify the interrupt tag in the 
mdio section.

I have to admit that I don't know how how systems without employing 
device tree get the phy interrupt configured, maybe someone can explain 
that shortly?

Nevertheless, other drivers for very common phys like the lxt971 also 
just set the function pointers to config_intr and ack_interrupt and also 
set the flag PHY_HAS_INTERRUPT. So I don't think that the my patch 
breaks something.

Regards,

Stephan
