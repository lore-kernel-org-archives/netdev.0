From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: bgmac: support Ethernet core on BCM53573
 SoCs
Date: Thu, 18 Aug 2016 23:36:24 -0700 (PDT)
Message-ID: <20160818.233624.1305767093109968469.davem@davemloft.net>
References: <1471467662-18319-1-git-send-email-zajec5@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=euc-kr
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, rafal@milecki.pl, jon.mason@broadcom.com,
        arnd@arndb.de, f.fainelli@gmail.com, tremyfr@gmail.com,
        nbd@openwrt.org, linux-kernel@vger.kernel.org,
        linux-wireless@vger.kernel.org
To: zajec5@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1471467662-18319-1-git-send-email-zajec5@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Rafa©© Mi©©ecki <zajec5@gmail.com>
Date: Wed, 17 Aug 2016 23:00:30 +0200

> From: Rafa©© Mi©©ecki <rafal@milecki.pl>
> 
> BCM53573 is a new series of Broadcom's SoCs. It's based on ARM and can
> be found in two packages (versions): BCM53573 and BCM47189. It shares
> some code with the Northstar family, but also requires some new quirks.
> 
> First of all there can be up to 2 Ethernet cores on this SoC. If that is
> the case, they are connected to two different switch ports allowing some
> more complex/optimized setups. It seems the second unit doesn't come
> fully configured and requires some IRQ quirk.
> 
> Other than that only the first core is connected to the PHY. For the
> second one we have to register fixed PHY (similarly to the Northstar),
> otherwise generic PHY driver would get some invalid info.
> 
> This has been successfully tested on Tenda AC9 (BCM47189B0).
> 
> Signed-off-by: Rafa©© Mi©©ecki <rafal@milecki.pl>

Applied.
