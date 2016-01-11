From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next v2 2/2] net: tc35815: Drop unused variable
Date: Sun, 10 Jan 2016 23:31:46 -0500 (EST)
Message-ID: <20160110.233146.1764868501463274315.davem@davemloft.net>
References: <1452438645-29440-1-git-send-email-linux@roeck-us.net>
	<1452438645-29440-2-git-send-email-linux@roeck-us.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	andrew@lunn.ch
To: linux@roeck-us.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1452438645-29440-2-git-send-email-linux@roeck-us.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Guenter Roeck <linux@roeck-us.net>
Date: Sun, 10 Jan 2016 07:10:45 -0800

> Commit e7f4dc3536a4 ("mdio: Move allocation of interrupts into core")
> removes some code from tc_mii_init(), but does not remove a now unused
> variable. This results in the following build warning.
> 
> drivers/net/ethernet/toshiba/tc35815.c: In function 'tc_mii_init':
> drivers/net/ethernet/toshiba/tc35815.c:670:6: warning: unused variable 'i'
> 
> Fixes: e7f4dc3536a4 ("mdio: Move allocation of interrupts into core")
> Cc: Andrew Lunn <andrew@lunn.ch>
> Acked-by: Andrew Lunn <andrew@lunn.ch>
> Signed-off-by: Guenter Roeck <linux@roeck-us.net>

Applied.
