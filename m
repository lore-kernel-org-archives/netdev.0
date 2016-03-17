From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] net: phy: at803x: Add support to control PHY LEDs
Date: Thu, 17 Mar 2016 09:59:35 -0700
Message-ID: <56EAE277.4050109@gmail.com>
References: <1458223147-16142-1-git-send-email-vishalthanki@gmail.com>
 <1458223147-16142-2-git-send-email-vishalthanki@gmail.com>
 <20160317145032.GB26019@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: ujhelyi.m@gmail.com, netdev@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>,
	Vishal Thanki <vishalthanki@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f172.google.com ([209.85.192.172]:32912 "EHLO
	mail-pf0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1031681AbcCQRBR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Mar 2016 13:01:17 -0400
Received: by mail-pf0-f172.google.com with SMTP id 124so128686537pfg.0
        for <netdev@vger.kernel.org>; Thu, 17 Mar 2016 10:01:17 -0700 (PDT)
In-Reply-To: <20160317145032.GB26019@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17/03/16 07:50, Andrew Lunn wrote:
> On Thu, Mar 17, 2016 at 02:59:07PM +0100, Vishal Thanki wrote:
>> The LEDs can be turned on and off by a sysfs interface
>> now. Write 0 to "led_enable" file to turn off the LEDs
>> and write 1 to turn on. The support is experimental
>> and can be enabled by kernel configuration option.
>>
>> Signed-off-by: Vishal Thanki <vishalthanki@gmail.com>
>> ---
>>  drivers/net/phy/Kconfig  |  7 +++++
>>  drivers/net/phy/at803x.c | 71 ++++++++++++++++++++++++++++++++++++++++++++++++
> 
> Hi Vishal
> 
> This solution seems specific to the at803. You should be thinking of a
> generic solution that all PHYs can use. eg add a new callback function
> to phy_driver, and put the sysfs handling code in phylib.

Indeed, maybe we should be considering using the existing LEDS subsystem
(drivers/leds/*) to expose the PHY LEDs to user-space in a standard way?
-- 
Florian
