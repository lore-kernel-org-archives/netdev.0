From: Gregory CLEMENT <gregory.clement@free-electrons.com>
Subject: Re: [PATCH net-next 5/5] net: dsa: mv88e6xxx: Implement the 6390 external MDIO bus
Date: Wed, 25 Jan 2017 09:13:05 +0100
Message-ID: <871svr36cu.fsf@free-electrons.com>
References: <1485266031-4980-1-git-send-email-andrew@lunn.ch>
        <1485266031-4980-6-git-send-email-andrew@lunn.ch>
        <20170125013230.GB5043@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev <netdev@vger.kernel.org>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Florian Fainelli <f.fainelli@gmail.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([62.4.15.54]:49983 "EHLO
        mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751297AbdAYINS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 25 Jan 2017 03:13:18 -0500
In-Reply-To: <20170125013230.GB5043@lunn.ch> (Andrew Lunn's message of "Wed,
        25 Jan 2017 02:32:30 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,
 
 On mer., janv. 25 2017, Andrew Lunn <andrew@lunn.ch> wrote:

>> diff --git a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
>> index 7d24add45e74..572d585dc1e2 100644
>> --- a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
>> +++ b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
>> @@ -387,6 +387,7 @@
>>  #define GLOBAL2_PTP_AVB_DATA	0x17
>>  #define GLOBAL2_SMI_PHY_CMD			0x18
>>  #define GLOBAL2_SMI_PHY_CMD_BUSY		BIT(15)
>> +#define GLOBAL2_SMI_PHY_CMD_EXTERNAL		BIT(13)
>>  #define GLOBAL2_SMI_PHY_CMD_MODE_22		BIT(12)
>>  #define GLOBAL2_SMI_PHY_CMD_OP_22_WRITE_DATA	((0x1 << 10) | \
>
> Hi Gregory
>
> Please could you check if the 88E6341 has an external MDIO. Global 2,
> register 0x18, bit 13.

I confirm that 88E6341 has Global 2, register 0x18, bit 13 referred as
"External access"

Gregory

>
> Thanks
> 	Andrew

-- 
Gregory Clement, Free Electrons
Kernel, drivers, real-time and embedded Linux
development, consulting, training and support.
http://free-electrons.com
