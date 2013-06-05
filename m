From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: sun4i-emac: remove erroneous assignment
Date: Tue, 04 Jun 2013 17:34:22 -0700 (PDT)
Message-ID: <20130604.173422.570856682520942101.davem@davemloft.net>
References: <3298610.K0DeJZEM4E@wuerfel>
	<20130604134034.GE3283@lukather>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: arnd@arndb.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, sr@denx.de, richard.genoud@gmail.com
To: maxime.ripard@free-electrons.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130604134034.GE3283@lukather>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Maxime Ripard <maxime.ripard@free-electrons.com>
Date: Tue, 4 Jun 2013 15:40:34 +0200

> On Mon, Jun 03, 2013 at 11:36:50PM +0200, Arnd Bergmann wrote:
>> The newly added sun4i-emac driver causes a build error when
>> CONFIG_NET_POLL_CONTROLLER is set, because it attempts to
>> assign a pointer to netdev->poll_controller, which has
>> been replaced with ops->ndo_poll_controller in 2.6.31!
>> 
>> The correct assignment is present as well, so we just need
>> to remove the wrong one.
> 
> Thanks for fixing this,
> Acked-by: Maxime Ripard <maxime.ripard@anandra.org>

Applied.
