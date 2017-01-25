From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next v6 2/4] net: dsa: mv88e6xxx: Add support for
 ethernet switch 88E6341
Date: Wed, 25 Jan 2017 03:02:49 +0100
Message-ID: <20170125020249.GB24034@lunn.ch>
References: <cover.b0e18efe751186768e720c341693117fdd4d3c16.1485288602.git-series.gregory.clement@free-electrons.com>
 <bb6e3987ee942277e99c78d1f28112d8b4ecb744.1485288602.git-series.gregory.clement@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
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
To: Gregory CLEMENT <gregory.clement@free-electrons.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <bb6e3987ee942277e99c78d1f28112d8b4ecb744.1485288602.git-series.gregory.clement@free-electrons.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> +	[MV88E6341] = {
> +		.prod_num = PORT_SWITCH_ID_PROD_NUM_6341,
> +		.family = MV88E6XXX_FAMILY_6341,
> +		.name = "Marvell 88E6341",
> +		.num_databases = 4096,
> +		.num_ports = 6,
> +		.port_base_addr = 0x10,
> +		.global1_addr = 0x1b,
> +		.age_time_coeff = 15000,

Hi Gregory

Please could you check this timer in the datasheet. There is currently
a bug in the mv88e6390 support code. I also set it to 15s. But in fact
it is 3.75 seconds. The 6341 might also use 3.75 seconds.

   Thanks
	Andrew
