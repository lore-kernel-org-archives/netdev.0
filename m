From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] gianfar: Call netif_carrier_off() prior to registration
Date: Tue, 03 Jun 2014 19:42:04 -0700
Message-ID: <538E877C.7080509@gmail.com>
References: <1401836138-13253-1-git-send-email-festevam@gmail.com>	<CAGVrzcaK6n53=W+ixN9Hibc3oOgEGe7FFMVTwWzUNOyL3jotfw@mail.gmail.com> <20140603.190526.241247147331404487.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: festevam@gmail.com, claudiu.manoil@freescale.com,
	netdev@vger.kernel.org, fabio.estevam@freescale.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f54.google.com ([209.85.219.54]:59591 "EHLO
	mail-oa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752110AbaFDCmG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jun 2014 22:42:06 -0400
Received: by mail-oa0-f54.google.com with SMTP id j17so7175626oag.41
        for <netdev@vger.kernel.org>; Tue, 03 Jun 2014 19:42:04 -0700 (PDT)
In-Reply-To: <20140603.190526.241247147331404487.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 03/06/2014 19:05, David Miller a =E9crit :
> From: Florian Fainelli <f.fainelli@gmail.com>
> Date: Tue, 3 Jun 2014 16:04:49 -0700
>
>> 2014-06-03 15:55 GMT-07:00 Fabio Estevam <festevam@gmail.com>:
>>> From: Fabio Estevam <fabio.estevam@freescale.com>
>>>
>>> Quoting David Miller:
>>> "At the moment you call register_netdev() the device is visible, no=
tifications
>>> are sent to userspace, and userland tools can try to bring the inte=
rface up
>>> and see the incorrect link state, before you do the netif_carrier_o=
ff().
>>>
>>> Said another way, between the register_netdev() and netif_carrier_o=
ff() call,
>>> userspace can see the device in an inconsistent state."
>>>
>>> So call netif_carrier_off() prior to register_netdev().
>>
>> Potentially all drivers implementing libphy correctly should be fixe=
d
>> to start with a carrier off until the phy library has determined
>> otherwise.
>
> Are you saying we should hold off on this gianfar patch?

Not at all, I think this patch is fine. If Fabio wants/can audit the=20
other Freescale drivers I think this should be beneficial.
--
=46lorian
