From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 06/14] net: dsa: Add support for hardware monitoring
Date: Fri, 24 Oct 2014 02:10:09 -0400 (EDT)
Message-ID: <20141024.021009.1407162505438540933.davem@davemloft.net>
References: <54488CE1.2000106@roeck-us.net>
	<20141024.010306.1939269479587208896.davem@davemloft.net>
	<5449E66B.6090902@roeck-us.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, netdev@vger.kernel.org, andrew@lunn.ch,
	linux-kernel@vger.kernel.org
To: linux@roeck-us.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5449E66B.6090902@roeck-us.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Guenter Roeck <linux@roeck-us.net>
Date: Thu, 23 Oct 2014 22:40:59 -0700

> I see two options for that:
> 
> - Add
> 	select HWMON
>   to the NET_DSA Kconfig entry.
>   Example is Broadcom TIGON3 driver.
> 
> - Add a DSA_HWMON Kconfig entry to define the dependencies and
>   to let the user select if the functionality should be enabled.
>   Example is Intel IGB driver.
> 
> Any preference from your side ? If no, I'll go with the latter.

Probably the latter is better, select can get you into trouble.
