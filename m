From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: mdio-mux: bcm-iproc: call mdiobus_free() in error
 path
Date: Mon, 08 May 2017 18:00:07 -0400 (EDT)
Message-ID: <20170508.180007.626860706220120048.davem@davemloft.net>
References: <1494280115-9252-1-git-send-email-jon.mason@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, netdev@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
        bcm-kernel-feedback-list@broadcom.com
To: jon.mason@broadcom.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1494280115-9252-1-git-send-email-jon.mason@broadcom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jon Mason <jon.mason@broadcom.com>
Date: Mon,  8 May 2017 17:48:35 -0400

> If an error is encountered in mdio_mux_init(), the error path will call
> mdiobus_free().  Since mdiobus_register() has been called prior to
> mdio_mux_init(), the bus->state will not be MDIOBUS_UNREGISTERED.  This
> causes a BUG_ON() in mdiobus_free().  To correct this issue, add an
> error path for mdio_mux_init() which calls mdiobus_unregister() prior to
> mdiobus_free().
> 
> Signed-off-by: Jon Mason <jon.mason@broadcom.com>
> Fixes: 98bc865a1ec8 ("net: mdio-mux: Add MDIO mux driver for iProc SoCs")

Applied and queued up for -stable.
