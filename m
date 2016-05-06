From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [RFC PATCH net-next 14/20] net: dsa: mv88e6xxx: factorize VLAN Ethertype
Date: Fri, 06 May 2016 11:12:56 -0400
Message-ID: <874mab9q4n.fsf@ketchup.mtl.sfl>
References: <1462488064-1841-1-git-send-email-vivien.didelot@savoirfairelinux.com> <1462488064-1841-15-git-send-email-vivien.didelot@savoirfairelinux.com> <20160506005759.GL7972@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:56422 "EHLO
	mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758037AbcEFPNA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 May 2016 11:13:00 -0400
In-Reply-To: <20160506005759.GL7972@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,

Andrew Lunn <andrew@lunn.ch> writes:

>> @@ -55,6 +58,7 @@ static const struct mv88e6xxx_info mv88e6131_table[] = {
>>  		.num_databases = 256,
>>  		.num_ports = 10,
>>  		.flags = MV88E6XXX_FLAG_ATU |
>> +			MV88E6XXX_FLAG_CORE_TAG_TYPE |
>>  			MV88E6XXX_FLAG_PPU |
>>  			MV88E6XXX_FLAG_VLANTABLE |
>>  			MV88E6XXX_FLAG_VTU,
>
> Rather than repeating these flags again and again, could you add one
> #define containing the flags, and then use that to initialise .flags.

Hum OK, I wasn't sure, but looking at the final mv88e6xxx_info table, I
can see that models from the same family all have the same set of flags,
even if they don't have the same number of ports or databases.

I'll add one MV88E6XXX_FLAGS_xxxx per family.

Thanks,

        Vivien
