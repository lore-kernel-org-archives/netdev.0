From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next 01/10] net: dsa: mv88e6xxx: add irl_init_all op
Date: Mon, 19 Jun 2017 10:24:36 -0400
Message-ID: <87bmpk838b.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <201706190418.ae0hjBaJ%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: kbuild-all@01.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>
To: kbuild test robot <lkp@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201706190418.ae0hjBaJ%fengguang.wu@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

kbuild test robot <lkp@intel.com> writes:

>    drivers/net/dsa/mv88e6xxx/serdes.o: In function `mv88e6352_g2_irl_init_all':
>>> serdes.c:(.text+0x150): multiple definition of `mv88e6352_g2_irl_init_all'
>    drivers/net/dsa/mv88e6xxx/chip.o:chip.c:(.text+0x3200): first defined here
>    drivers/net/dsa/mv88e6xxx/serdes.o: In function `mv88e6390_g2_irl_init_all':
>>> serdes.c:(.text+0x160): multiple definition of `mv88e6390_g2_irl_init_all'
>    drivers/net/dsa/mv88e6xxx/chip.o:chip.c:(.text+0x0): first defined here

My bad, missing "static inline" in global2.h, respining.
