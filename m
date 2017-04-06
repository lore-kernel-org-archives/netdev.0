From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH 3/4] net: dsa: LAN9303: add I2C managed mode support
Date: Thu, 6 Apr 2017 06:52:06 -0700
Message-ID: <c5f2bc76-c563-d990-f5b0-79b8856d0950@gmail.com>
References: <20170405092024.16048-1-jbe@pengutronix.de>
 <20170405092024.16048-4-jbe@pengutronix.de> <20170405182155.GF21965@lunn.ch>
 <201704061546.04478.jbe@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@pengutronix.de, vivien.didelot@savoirfairelinux.com,
        davem@davemloft.net
To: Juergen Borleis <jbe@pengutronix.de>, Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:35391 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753945AbdDFNwJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 6 Apr 2017 09:52:09 -0400
In-Reply-To: <201704061546.04478.jbe@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 04/06/2017 06:46 AM, Juergen Borleis wrote:
>>> +		phy-reset-gpios = <&gpio7 6 GPIO_ACTIVE_LOW>;
>>> +		phy-reset-duration = <200>;
>>> +
>>> +		dsa,member = <0 0>;
>>> +
>>> +		ports {
>>> +			#address-cells = <1>;
>>> +			#size-cells = <0>;
>>> +
>>> +			port@0 { /* RMII fixed link to master */
>>> +				reg = <0>;
>>> +				label = "cpu";
>>> +				ethernet = <&master>;
>>> +				max-speed = <100>;
>>
>> max-speed does not do anything i think, since there is no adjust_link
>> function.

Since port 0 is the CPU port, we expect to find a fixed PHY for it, so
yes, this won't do much because fixed-link already appropriately limits
the speed.
-- 
Florian
