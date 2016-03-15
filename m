From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] bus: mvebu-mbus: use %pad to print phys_addr_t
Date: Tue, 15 Mar 2016 03:09:00 -0700
Message-ID: <1458036540.11972.183.camel@perches.com>
References: <1458036233-2770406-1-git-send-email-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Marcin Wojtas <mw@semihalf.com>, Evan Wang <xswang@marvell.com>,
	Gregory CLEMENT <gregory.clement@free-electrons.com>,
	netdev@vger.kernel.org,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Nicolas Schichan <nschichan@freebox.fr>,
	linux-kernel@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>,
	"David S . Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1458036233-2770406-1-git-send-email-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2016-03-15 at 11:03 +0100, Arnd Bergmann wrote:
> A recent change to the mbus driver added a warning printk that
> prints a phys_addr_t using the %x format string, which fails in
> case we build with 64-bit phys_addr_t:

Hey Arnd.

This is a bad patch subject, %pad is for a dma_addr_t.
The patch subject made me assume the patch was incorrect.

> > This uses the special %pa format string instead, so we always
> print the correct type.
[]
> -	pr_err("invalid dram address 0x%x\n", phyaddr);
> +	pr_err("invalid dram address %pa\n", &phyaddr);

The patch is good though.
