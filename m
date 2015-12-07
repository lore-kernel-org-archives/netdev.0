From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v3 net-next 0/4] Further fix for dsa unbinding
Date: Mon, 7 Dec 2015 15:28:08 +0100
Message-ID: <20151207142808.GG1118@lunn.ch>
References: <56321D9A.8010109@baylibre.com>
 <1449493055-29047-1-git-send-email-narmstrong@baylibre.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, f.fainelli@gmail.com, linux@roeck-us.net,
	vivien.didelot@savoirfairelinux.com, fabf@skynet.be,
	pavel.nakonechny@skitlab.ru, joe@perches.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Neil Armstrong <narmstrong@baylibre.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1449493055-29047-1-git-send-email-narmstrong@baylibre.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Dec 07, 2015 at 01:57:31PM +0100, Neil Armstrong wrote:
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

Acked-by: Andrew Lunn <andrew@lunn.ch>

Thanks
	Andrew
