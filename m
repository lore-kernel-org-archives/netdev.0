From: Gregory CLEMENT <gregory.clement@free-electrons.com>
Subject: Re: [PATCH net-next v6 2/4] net: dsa: mv88e6xxx: Add support for ethernet switch 88E6341
Date: Wed, 25 Jan 2017 08:55:42 +0100
Message-ID: <8760l3375t.fsf@free-electrons.com>
References: <cover.b0e18efe751186768e720c341693117fdd4d3c16.1485288602.git-series.gregory.clement@free-electrons.com>
        <bb6e3987ee942277e99c78d1f28112d8b4ecb744.1485288602.git-series.gregory.clement@free-electrons.com>
        <20170125020249.GB24034@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        "David S. Miller" <davem@davemloft.net>,
        Jason Cooper <jason@lakedaemon.net>,
        Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
        Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
        linux-arm-kernel@lists.infradead.org,
        Nadav Haklai <nadavh@marvell.com>,
        Wilson Ding <dingwei@marvell.com>,
        Kostya Porotchkin <kostap@marvell.com>,
        Joe Zhou <shjzhou@marvell.com>,
        Jon Pannell <jpannell@marvell.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([62.4.15.54]:49762 "EHLO
        mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751309AbdAYH4F (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 25 Jan 2017 02:56:05 -0500
In-Reply-To: <20170125020249.GB24034@lunn.ch> (Andrew Lunn's message of "Wed,
        25 Jan 2017 03:02:49 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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

When I read your series I also thought about it and indeed it is 3.75
seconds. I will fix it.

Thanks,

Gregory


>
>    Thanks
> 	Andrew

-- 
Gregory Clement, Free Electrons
Kernel, drivers, real-time and embedded Linux
development, consulting, training and support.
http://free-electrons.com
