From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH 3/3] net: dsa: mv88e6352: add support for port_vlan_dump
Date: Fri, 26 Jun 2015 10:33:16 -0400 (EDT)
Message-ID: <1052297361.304968.1435329196722.JavaMail.zimbra@savoirfairelinux.com>
References: <1435095970-18576-1-git-send-email-vivien.didelot@savoirfairelinux.com> <1435095970-18576-4-git-send-email-vivien.didelot@savoirfairelinux.com> <20150626141217.GD9469@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, David <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Guenter Roeck <linux@roeck-us.net>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	kernel <kernel@savoirfairelinux.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([209.172.62.77]:65383 "EHLO
	mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752824AbbFZOdT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Jun 2015 10:33:19 -0400
In-Reply-To: <20150626141217.GD9469@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,

On Jun 26, 2015, at 10:12 AM, Andrew Lunn andrew@lunn.ch wrote:

> On Tue, Jun 23, 2015 at 05:46:10PM -0400, Vivien Didelot wrote:
>> Add support for dumping the VLAN Table Unit entries by pointing to the
>> port_vlan_dump function implemented for mv88e6xxx.
>> 
>> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
>> ---
>>  drivers/net/dsa/mv88e6352.c | 1 +
>>  1 file changed, 1 insertion(+)
>> 
>> diff --git a/drivers/net/dsa/mv88e6352.c b/drivers/net/dsa/mv88e6352.c
>> index b524bd3..c35f57f 100644
>> --- a/drivers/net/dsa/mv88e6352.c
>> +++ b/drivers/net/dsa/mv88e6352.c
>> @@ -397,6 +397,7 @@ struct dsa_switch_driver mv88e6352_switch_driver = {
>>  	.fdb_add		= mv88e6xxx_port_fdb_add,
>>  	.fdb_del		= mv88e6xxx_port_fdb_del,
>>  	.fdb_getnext		= mv88e6xxx_port_fdb_getnext,
>> +	.port_vlan_dump		= mv88e6xxx_port_vlan_dump,
>>  };
> 
> Once the code is made generic in terms of number of ports, i would
> suggest adding this to all drivers which support it. Between us, we
> can test most of them.
> 
> Thanks
> 	Andrew

OK. I'll add it in mv88e6352.c, mv88e6171.c, mv88e6131.c, mv88e6123_61_65.c.

Thanks,
-v
