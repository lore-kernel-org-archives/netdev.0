From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Revert "net: phy: Set the driver when registering an
 MDIO bus device"
Date: Tue, 05 Aug 2014 16:42:19 -0700 (PDT)
Message-ID: <20140805.164219.1353576887891215623.davem@davemloft.net>
References: <1407237222-3148-1-git-send-email-festevam@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, linux@arm.linux.org.uk,
	shawn.guo@freescale.com, netdev@vger.kernel.org,
	ezequiel.garcia@free-electrons.com, fabio.estevam@freescale.com,
	stable@vger.kernel.org
To: festevam@gmail.com
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <1407237222-3148-1-git-send-email-festevam@gmail.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Fabio Estevam <festevam@gmail.com>
Date: Tue,  5 Aug 2014 08:13:42 -0300

> From: Fabio Estevam <fabio.estevam@freescale.com>
> 
> Commit a71e3c37960ce5f9 ("net: phy: Set the driver when registering an MDIO bus
> device") caused the following regression on the fec driver:
 ...
> The problem with the original commit is explained by Russell King:
> 
> "It has the effect (as can be seen from the oops) of attaching the MDIO bus
> device (itself is a bus-less device) to the platform driver, which means
> that if the platform driver supports power management, it will be called
> to power manage the MDIO bus device.
> 
> Moreover, drivers do not expect to be called for power management
> operations for devices which they haven't probed, and certainly not for
> devices which aren't part of the same bus that the driver is registered
> against."
> 
> This reverts commit a71e3c37960ce5f9c6a519bc1215e3ba9fa83e75.
> 
> Cc: <stable@vger.kernel.org> #3.16
> Signed-off-by: Fabio Estevam <fabio.estevam@freescale.com>

Applied, and queued up for -stable, thanks.
