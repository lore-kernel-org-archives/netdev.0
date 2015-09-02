From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: Re: [net-next PATCH] drivers: net: cpsw: Add support to make gpio
 drive which slave connected to phy
Date: Wed, 2 Sep 2015 12:03:10 +0530
Message-ID: <55E69826.7090503@ti.com>
References: <1441106719-5896-1-git-send-email-mugunthanvnm@ti.com>
 <20150901153621.GI4215@atomide.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, "David S . Miller" <davem@davemloft.net>,
	Sekhar Nori <nsekhar@ti.com>, <linux-omap@vger.kernel.org>
To: Tony Lindgren <tony@atomide.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bear.ext.ti.com ([192.94.94.41]:39097 "EHLO bear.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750856AbbIBGdX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Sep 2015 02:33:23 -0400
In-Reply-To: <20150901153621.GI4215@atomide.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 01 September 2015 09:06 PM, Tony Lindgren wrote:
> * Mugunthan V N <mugunthanvnm@ti.com> [150901 04:28]:
>> --- a/Documentation/devicetree/bindings/net/cpsw.txt
>> +++ b/Documentation/devicetree/bindings/net/cpsw.txt
>> @@ -26,6 +26,9 @@ Optional properties:
>>  - dual_emac		: Specifies Switch to act as Dual EMAC
>>  - syscon		: Phandle to the system control device node, which is
>>  			  the control module device of the am33x
>> +- select-slave-gpio	: Should be added if a gpio line is required to
>> +			  select which slave is connected to phy
>> +
> 
> How about using something more generic here for the name?
> Something like mode-gpios?
> 

Yeah, agreed, for DRA72x it is used for connecting to phy, if some other
board wanted to drive a GPIO for something else we can use this node to
drive GPIO.

Will submit a v2 with name change

Regards
Mugunthan V N
