From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: Broadcom BCM54610 Linux support
Date: Tue, 07 Jul 2015 10:34:56 -0700
Message-ID: <559C0DC0.9070003@gmail.com>
References: <20150707105824.GK4552@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Michael Chan <mchan@broadcom.com>
To: Markus Pargmann <mpa@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:35169 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932237AbbGGRgj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jul 2015 13:36:39 -0400
Received: by pactm7 with SMTP id tm7so116571807pac.2
        for <netdev@vger.kernel.org>; Tue, 07 Jul 2015 10:36:38 -0700 (PDT)
In-Reply-To: <20150707105824.GK4552@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(adding Michael)

On 07/07/15 03:58, Markus Pargmann wrote:
> Hi,
> 
> I found the phy driver which supports broadcom BCM5461. But I am not
> sure if this driver does support BCM54610 in fiber mode as well? Or if
> there are any open datasheets which could be used to write a mainline
> driver for it. I would appretiate any information about this.

There are not publicly available datasheets as far as I can tell, the
current driver does not support anything but copper modes.

If you have reference code from somewhere else (e.g: bootloader or a
Broadcom SDK), I would be inclined to port it over the Linux PHY driver.
-- 
Florian
