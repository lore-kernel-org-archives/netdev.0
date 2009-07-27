From: Wolfgang Grandegger <wg@grandegger.com>
Subject: Re: [PATCH] Add Support for Freescale FlexCAN CAN controller
Date: Mon, 27 Jul 2009 11:25:15 +0200
Message-ID: <4A6D727B.7030304@grandegger.com>
References: <20090724131933.GL2714@pengutronix.de>	<4A69CB46.1090704@grandegger.com> <20090727062559.GP2714@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Socketcan-core@lists.berlios.de,
	Linux Netdev List <netdev@vger.kernel.org>
To: Sascha Hauer <s.hauer@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.9]:55024 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754487AbZG0JZQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jul 2009 05:25:16 -0400
In-Reply-To: <20090727062559.GP2714@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sascha Hauer wrote:
> On Fri, Jul 24, 2009 at 04:55:02PM +0200, Wolfgang Grandegger wrote:
>> Hi Sascha,
>>
>> Sascha Hauer wrote:
>>> Hi,
>>>
>>> This patch adds support for the Freescale FlexCAN CAN controller.
>>> The driver has been tested on an i.MX25 SoC with bitrates up to
>>> 1Mbit, remote frames and standard and extenden frames.
>>>
>>> Please review and consider for inclusion.
>> See below...
>>
>>> Sascha
>>>
>>>
>>> >From 94a607390f0d7b181e2ffdfe16a05f3aaca15ab9 Mon Sep 17 00:00:00 2001
>>> From: Sascha Hauer <s.hauer@pengutronix.de>
>>> Date: Tue, 21 Jul 2009 10:47:19 +0200
>>> Subject: [PATCH] Add Flexcan CAN driver
>> The prefix "can:" would be nice here.
> 
> Ok, I'll add it next round.
> 
>>> This core is found on some Freescale SoCs and also some Coldfire
>>> SoCs. Support for Coldfire is missing though at the moment as
>>> they have an older revision of the core which does not have RX FIFO
>>> support.
>>>
>>> Signed-off-by: Sascha Hauer <s.hauer@pengutronix.de>
>>> ---
>>>  drivers/net/can/Kconfig   |    6 +
>>>  drivers/net/can/Makefile  |    1 +
>>>  drivers/net/can/flexcan.c |  696 +++++++++++++++++++++++++++++++++++++++++++++
>>>  3 files changed, 703 insertions(+), 0 deletions(-)
>>>  create mode 100644 drivers/net/can/flexcan.c
>>>
>>> diff --git a/drivers/net/can/Kconfig b/drivers/net/can/Kconfig
>>> index 33821a8..99c6da4 100644
>>> --- a/drivers/net/can/Kconfig
>>> +++ b/drivers/net/can/Kconfig
[...]
>>> +	kfree_skb(skb);
>> Support for echo skb using can_put/get_echo_skb() is missing. It should
>> not be a big deal to add it.
> 
> In fact it's not missing, but the hardware is configured to receive its
> own packets, so this isn't needed.

But the user may disable IFF_ECHO, which should be handled somehow.

Wolfgang.
