From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH v3 net-next 0/4] Further fix for dsa unbinding
Date: Mon, 07 Dec 2015 12:39:26 -0800
Message-ID: <5665EE7E.9020600@gmail.com>
References: <56321D9A.8010109@baylibre.com> <1449493055-29047-1-git-send-email-narmstrong@baylibre.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: Neil Armstrong <narmstrong@baylibre.com>, davem@davemloft.net,
	andrew@lunn.ch, linux@roeck-us.net,
	vivien.didelot@savoirfairelinux.com, fabf@skynet.be,
	pavel.nakonechny@skitlab.ru, joe@perches.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1449493055-29047-1-git-send-email-narmstrong@baylibre.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 07/12/15 04:57, Neil Armstrong wrote:
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
> 
> Neil Armstrong (4):
>   net: dsa: remove DSA link polling
>   net: dsa: cleanup resources upon module removal
>   net: dsa: Add missing master netdev dev_put() calls
>   net: dsa: move dsa slave destroy code to slave.c

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
