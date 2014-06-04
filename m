From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] gianfar: Call netif_carrier_off() prior to registration
Date: Tue, 03 Jun 2014 19:05:26 -0700 (PDT)
Message-ID: <20140603.190526.241247147331404487.davem@davemloft.net>
References: <1401836138-13253-1-git-send-email-festevam@gmail.com>
	<CAGVrzcaK6n53=W+ixN9Hibc3oOgEGe7FFMVTwWzUNOyL3jotfw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: festevam@gmail.com, claudiu.manoil@freescale.com,
	netdev@vger.kernel.org, fabio.estevam@freescale.com
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50852 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751883AbaFDCF1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jun 2014 22:05:27 -0400
In-Reply-To: <CAGVrzcaK6n53=W+ixN9Hibc3oOgEGe7FFMVTwWzUNOyL3jotfw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Tue, 3 Jun 2014 16:04:49 -0700

> 2014-06-03 15:55 GMT-07:00 Fabio Estevam <festevam@gmail.com>:
>> From: Fabio Estevam <fabio.estevam@freescale.com>
>>
>> Quoting David Miller:
>> "At the moment you call register_netdev() the device is visible, notifications
>> are sent to userspace, and userland tools can try to bring the interface up
>> and see the incorrect link state, before you do the netif_carrier_off().
>>
>> Said another way, between the register_netdev() and netif_carrier_off() call,
>> userspace can see the device in an inconsistent state."
>>
>> So call netif_carrier_off() prior to register_netdev().
> 
> Potentially all drivers implementing libphy correctly should be fixed
> to start with a carrier off until the phy library has determined
> otherwise.

Are you saying we should hold off on this gianfar patch?
