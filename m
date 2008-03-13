From: "Bosko Radivojevic" <bosko.radivojevic@gmail.com>
Subject: Re: MACB driver question
Date: Thu, 13 Mar 2008 08:47:43 +0100
Message-ID: <d6c8ef150803130047k1718f65dm6b35d44de44fcd79@mail.gmail.com>
References: <d6c8ef150803120804qfd2f57ds509ddf40c5ddbb11@mail.gmail.com>
	 <20080313011237.3119f8e8@siona.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Haavard Skinnemoen" <hskinnemoen@atmel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.251]:1925 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750783AbYCMHrp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Mar 2008 03:47:45 -0400
Received: by an-out-0708.google.com with SMTP id d31so789630and.103
        for <netdev@vger.kernel.org>; Thu, 13 Mar 2008 00:47:44 -0700 (PDT)
In-Reply-To: <20080313011237.3119f8e8@siona.local>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

When I boot kernel with compiled-in Fixed PHY support on the board
with Micrel PHY I get:
MACB_mii_bus: probed
eth0: Atmel MACB at 0xfffc4000 irq 21 (00:00:00:00:00:00)
eth0: attached PHY driver [Fixed PHY] (mii_bus:phy_addr=ffffffff:01, irq=-1)

(Actually, this board works with generic phy support also very fine)

On the other hand, when booting the same kernel on the similar board
but without PHY (MAC in AT91SAM9260 connected directly with EtherCAT
ET1200 ASIC) I get:

MACB_mii_bus: probed
eth0: no PHY found

Kernel version is 2.6.24.3, part of .config:

CONFIG_FIXED_PHY=y
CONFIG_FIXED_MII_100_FDX=y
CONFIG_FIXED_MII_AMNT=1
CONFIG_NET_ETHERNET=y
CONFIG_MACB=y

On Thu, Mar 13, 2008 at 1:12 AM, Haavard Skinnemoen
<hskinnemoen@atmel.com> wrote:
>
> On Wed, 12 Mar 2008 16:04:27 +0100
>  "Bosko Radivojevic" <bosko.radivojevic@gmail.com> wrote:
>
>  > Hi Haavard!
>  >
>  > I have question regarding MACB driver. Actually, I want to use it
>  > without connected PHY (we connected MACB directly to EtherCAT ET1200
>  > asic). In previous versions (2.6.20) I've manually removed all
>  > phy-related parts from macb.c at it works good. Now, when there is PHY
>  > API is there any 'nice and clean' way for doing it? I've tried with
>  > Fixed PHY, but it is not working (I get "No PHY found" message). For
>  > the test purposes, I tried the same with another board with Micrel's
>  > PHY and it works (with Fixed PHY, 100/Full).
>
>  Sorry, I don't have much experience with the Fixed PHY driver, but I
>  was under the impression that this is the sort of thing it was meant
>  for. Maybe someone at the Netdev list can help?
>
>  (dropping linux-arm from Cc becase it's subscribers-only and it was the
>  wrong list to begin with.)
>
>  Haavard
>
