From: Jon Pannell <jpannell@marvell.com>
Subject: RE: [PATCH net-next v6 2/4] net: dsa: mv88e6xxx: Add support for
 ethernet switch 88E6341
Date: Wed, 25 Jan 2017 18:58:25 +0000
Message-ID: <39e62380a498403d94961d066a8bba6b@SC-EXCH01.marvell.com>
References: <cover.b0e18efe751186768e720c341693117fdd4d3c16.1485288602.git-series.gregory.clement@free-electrons.com>
        <bb6e3987ee942277e99c78d1f28112d8b4ecb744.1485288602.git-series.gregory.clement@free-electrons.com>
        <20170125020249.GB24034@lunn.ch> <8760l3375t.fsf@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        Jason Cooper <jason@lakedaemon.net>,
        "Sebastian Hesselbarth" <sebastian.hesselbarth@gmail.com>,
        Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
        "linux-arm-kernel@lists.infradead.org"
        <linux-arm-kernel@lists.infradead.org>,
        Nadav Haklai <nadavh@marvell.com>,
        Wilson Ding <dingwei@marvell.com>,
        Kostya Porotchkin <kostap@marvell.com>,
        Joe Zhou <shjzhou@marvell.com>
To: Gregory CLEMENT <gregory.clement@free-electrons.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Bob Bernstein <robertb@marvell.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016f401.pphosted.com ([67.231.148.174]:47667 "EHLO
        mx0b-0016f401.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751658AbdAYTAO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 25 Jan 2017 14:00:14 -0500
In-Reply-To: <8760l3375t.fsf@free-electrons.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adding Bob Bernstein

Jon Pannell


-----Original Message-----
From: Gregory CLEMENT [mailto:gregory.clement@free-electrons.com] 
Sent: Tuesday, January 24, 2017 11:56 PM
To: Andrew Lunn <andrew@lunn.ch>
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>; Florian Fainelli <f.fainelli@gmail.com>; netdev@vger.kernel.org; linux-kernel@vger.kernel.org; David S. Miller <davem@davemloft.net>; Jason Cooper <jason@lakedaemon.net>; Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>; Thomas Petazzoni <thomas.petazzoni@free-electrons.com>; linux-arm-kernel@lists.infradead.org; Nadav Haklai <nadavh@marvell.com>; Wilson Ding <dingwei@marvell.com>; Kostya Porotchkin <kostap@marvell.com>; Joe Zhou <shjzhou@marvell.com>; Jon Pannell <jpannell@marvell.com>
Subject: Re: [PATCH net-next v6 2/4] net: dsa: mv88e6xxx: Add support for ethernet switch 88E6341

Hi Andrew,
 
 On mer., janv. 25 2017, Andrew Lunn <andrew@lunn.ch> wrote:

>> +	[MV88E6341] = {
>> +		.prod_num = PORT_SWITCH_ID_PROD_NUM_6341,
>> +		.family = MV88E6XXX_FAMILY_6341,
>> +		.name = "Marvell 88E6341",
>> +		.num_databases = 4096,
>> +		.num_ports = 6,
>> +		.port_base_addr = 0x10,
>> +		.global1_addr = 0x1b,
>> +		.age_time_coeff = 15000,
>
> Hi Gregory
>
> Please could you check this timer in the datasheet. There is currently 
> a bug in the mv88e6390 support code. I also set it to 15s. But in fact 
> it is 3.75 seconds. The 6341 might also use 3.75 seconds.

When I read your series I also thought about it and indeed it is 3.75 seconds. I will fix it.

Thanks,

Gregory


>
>    Thanks
> 	Andrew
