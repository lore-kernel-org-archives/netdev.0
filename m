From: Gal Pressman <galp@mellanox.com>
Subject: Re: [RFC PATCH net-next 1/3] ethtool: Add link down reason callback
Date: Fri, 23 Jun 2017 11:23:17 +0300
Message-ID: <b6bbfe70-b4df-fbba-21d9-ddb3ce1eaebd@mellanox.com>
References: <1498050286-17141-1-git-send-email-galp@mellanox.com>
 <1498050286-17141-2-git-send-email-galp@mellanox.com>
 <20170621135809.GC27585@lunn.ch>
 <8e7ffead-350e-bd7f-c7ea-fe057969d0d3@mellanox.com>
 <20170622133404.GB20038@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
        "John W. Linville" <linville@tuxdriver.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Vidya Sagar Ravipati <vidya@cumulusnetworks.com>,
        Jiri Pirko <jiri@mellanox.com>,
        David Decotigny <decot@googlers.com>, kernel-team@fb.com
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-eopbgr30083.outbound.protection.outlook.com ([40.107.3.83]:63408
        "EHLO EUR03-AM5-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1754123AbdFWIXd (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 23 Jun 2017 04:23:33 -0400
In-Reply-To: <20170622133404.GB20038@lunn.ch>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> The I2C bus that's connected to this module (interface).
>> We can add another reason for MDIO BUS errors or merge to one BUS error reason.
>>>> +	ETHTOOL_LINK_UNSUPP_EEPROM, /* Unsupported EEPROM */
>>> Which EEPROM?
>> Module EEPROM.
> Which module? This is all very vague. Some of the Marvell 10G PHYs
> have an EEPROM to boot from, for example. Would that count? Or are you
> talking about the SFP 'EEPROM', which is not actually an EEPROM, in
> that it is not Electrically Erasable, not is it a ROM, since things
> like temperature changes with time.

I am referring to the optical/electrical module EEPROM which is exposed through standard
interface such as SFF 8472. Might not be an actual EEPROM but that's how the SFF committee decided
to refer to it :).

>
>>>> +	ETHTOOL_LINK_OVERTEMP, /* Over temperature */
>>>> +	ETHTOOL_LINK_PWR_BUDGET_EXC, /* Power budget exceeded */
>>>> +	ETHTOOL_LINK_MODULE_ADMIN_DOWN, /* Module admin down */
>>> It seems like these last 6 are all SFP issues? How about putting SFP
>>> into the name?
>> Might be a QSFP issue for example, we can put module in the name though.
> What is the generic name of SFP, SFP+ QSFP, SFF?

AFAIK, the name is module.
>
>      Andrew
