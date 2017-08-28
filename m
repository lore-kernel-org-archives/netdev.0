From: Grygorii Strashko <grygorii.strashko@ti.com>
Subject: Re: Fwd: DA850-evm MAC Address is random
Date: Mon, 28 Aug 2017 13:54:45 -0500
Message-ID: <b7aab9fc-17ba-077b-3ff3-28087e0b25bc@ti.com>
References: <CAHCN7xKwFd7dHF0ySEd1hOSr0sZEgh9fuwy=RkUTHvEh59hojQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
To: Adam Ford <aford173@gmail.com>, <linux-omap@vger.kernel.org>,
        <netdev@vger.kernel.org>, Sekhar Nori <nsekhar@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lelnx194.ext.ti.com ([198.47.27.80]:29750 "EHLO
        lelnx194.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751203AbdH1Syq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Aug 2017 14:54:46 -0400
In-Reply-To: <CAHCN7xKwFd7dHF0ySEd1hOSr0sZEgh9fuwy=RkUTHvEh59hojQ@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cc: Sekhar

On 08/28/2017 10:32 AM, Adam Ford wrote:
> The davinvi_emac MAC address seems to attempt a call to
> ti_cm_get_macid in cpsw-common.c but it returns the message
> 'davinci_emac davinci_emac.1: incompatible machine/device type for
> reading mac address ' and then generates a random MAC address.
> 
> The function appears to lookup varions boards using
> 'of_machine_is_compaible' and supports dm8148, am33xx, am3517, dm816,
> am4372 and dra7.  I don't see the ti,davinci-dm6467-emac which is
> what's shown in the da850 device tree.
> 
> Is there a patch somewhere for supporting the da850-evm?

Not sure if MAC address can be read from Control module.
May be Sekhar can say more?

> 
> If not, is there a way to pass the MAC address from U-Boot to the
> driver so it doesn't generate a random MAC?

"local-mac-address" dt porp

-- 
regards,
-grygorii
