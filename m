From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: dsa: Fix scope of eeprom-length property
Date: Wed, 29 Apr 2015 15:35:37 -0400 (EDT)
Message-ID: <20150429.153537.1133417231536766459.davem@davemloft.net>
References: <1430330175-21977-1-git-send-email-linux@roeck-us.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andrew@lunn.ch, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: linux@roeck-us.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1430330175-21977-1-git-send-email-linux@roeck-us.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Guenter Roeck <linux@roeck-us.net>
Date: Wed, 29 Apr 2015 10:56:15 -0700

> eeprom-length is a switch property, not a dsa property, and thus
> needs to be attached to the switch node, not to the dsa node.
> 
> Reported-by: Andrew Lunn <andrew@lunn.ch>
> Fixes: 6793abb4e849 ("net: dsa: Add support for switch EEPROM access")
> Signed-off-by: Guenter Roeck <linux@roeck-us.net>

Applied, thanks.
