From: Moritz Fischer <moritz.fischer@ettus.com>
Subject: Re: [PATCH 0/3] net: macb: Fix coding style issues
Date: Wed, 9 Mar 2016 09:18:11 -0800
Message-ID: <CAAtXAHd9AV4Ca4HyOOUEd9bgQztL7FaDRQZONVs+XA2-qEbdDw@mail.gmail.com>
References: <1457367460-9123-1-git-send-email-moritz.fischer@ettus.com>
	<56DDB6CA.8000100@atmel.com>
	<56E04F73.6030504@xilinx.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Nicolas Ferre <nicolas.ferre@atmel.com>,
	Cyrille Pitchen <cyrille.pitchen@atmel.com>,
	David Miller <davem@davemloft.net>,
	Punnaiah Choudary Kalluri <punnaia@xilinx.com>,
	netdev@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Michal Simek <michal.simek@xilinx.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f44.google.com ([209.85.213.44]:35130 "EHLO
	mail-vk0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933466AbcCIRSN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Mar 2016 12:18:13 -0500
Received: by mail-vk0-f44.google.com with SMTP id e6so63883059vkh.2
        for <netdev@vger.kernel.org>; Wed, 09 Mar 2016 09:18:12 -0800 (PST)
In-Reply-To: <56E04F73.6030504@xilinx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

thanks for the feedback.

On Wed, Mar 9, 2016 at 8:29 AM, Michal Simek <michal.simek@xilinx.com> wrote:
> On 7.3.2016 18:13, Nicolas Ferre wrote:

>> I'm not usually fond of this type of patches, but I must admit that this
>> series corrects some style issues.

While I was playing around with my fixed-link for macb RFC I was
flooded with warnings,
so I figured I'll fix it while I'm at it. Just makes it easier for
other people to work
on it afterwards I thought.

>
>         mac = of_get_mac_address(np);
>         if (mac)
> -               memcpy(bp->dev->dev_addr, mac, ETH_ALEN);
> +               ether_addr_copy(bp->dev->dev_addr, mac);
>         else

So don't you like this in general or just would like to have it split
out in a separate patch?

> Also extending scope of variables is not the right way to go. Especially
> when some automation tools are reporting that you should reduce scope of
> use for them. Wolfram is checking it for example.

Alright, understood, I'll address this.

Cheers,

Moritz
