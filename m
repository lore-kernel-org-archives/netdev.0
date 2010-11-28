From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] au1000_eth: fix invalid address accessing the MAC
 enable register
Date: Sun, 28 Nov 2010 11:31:35 -0800 (PST)
Message-ID: <20101128.113135.242124850.davem@davemloft.net>
References: <4CEBEE79.8040507@grandegger.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Netdev@vger.kernel.org, linux-mips@linux-mips.org,
	florian@openwrt.org
To: wg@grandegger.com
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <4CEBEE79.8040507@grandegger.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wolfgang Grandegger <wg@grandegger.com>
Date: Tue, 23 Nov 2010 17:40:25 +0100

> "aup->enable" holds already the address pointing to the MAC enable
> register. The bug was introduced by commit d0e7cb:
> 
> "au1000-eth: remove volatiles, switch to I/O accessors".
> 
> CC: Florian Fainelli <florian@openwrt.org>
> Signed-off-by: Wolfgang Grandegger <wg@denx.de>
> Acked-by: Florian Fainelli <florian@openwrt.org>

Applied, thanks.
