From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 net-next 0/4] Further fix for dsa unbinding
Date: Mon, 07 Dec 2015 16:36:08 -0500 (EST)
Message-ID: <20151207.163608.1805578623951785262.davem@davemloft.net>
References: <56321D9A.8010109@baylibre.com>
	<1449493055-29047-1-git-send-email-narmstrong@baylibre.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andrew@lunn.ch, f.fainelli@gmail.com, linux@roeck-us.net,
	vivien.didelot@savoirfairelinux.com, fabf@skynet.be,
	pavel.nakonechny@skitlab.ru, joe@perches.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: narmstrong@baylibre.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1449493055-29047-1-git-send-email-narmstrong@baylibre.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Neil Armstrong <narmstrong@baylibre.com>
Date: Mon,  7 Dec 2015 13:57:31 +0100

> This serie fixes further issues for DSA dynamic unbinding.
> The first patch completely removes the PHY link state polling.
> The two following cleans up the dsa state upon removal.
> The last patch moves slave destroy code as slave function and
> adds missing netdev and phy cleanup calls.
> 
> v1: http://lkml.kernel.org/r/562F8ECB.6050709@baylibre.com
> v2: http://lkml.kernel.org/r/56321D9A.8010109@baylibre.com
> remove phy fix and add missing calls in dsa_switch_destroy
> then add dedicated dsa_slave_destroy
> 
> v3: remove polling instead of fixing it, make single patch for
> dsa slave destroy

Series applied, thanks Neil.
