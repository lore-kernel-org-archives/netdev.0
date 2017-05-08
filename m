From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] net: mdio-mux: bcm-iproc: call mdiobus_free() in error
 path
Date: Mon, 8 May 2017 14:53:38 -0700
Message-ID: <43692ac5-6db4-2ab1-737c-424be7db20f7@gmail.com>
References: <1494280115-9252-1-git-send-email-jon.mason@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
        linux-kernel@vger.kernel.org, bcm-kernel-feedback-list@broadcom.com
To: Jon Mason <jon.mason@broadcom.com>,
        Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1494280115-9252-1-git-send-email-jon.mason@broadcom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 05/08/2017 02:48 PM, Jon Mason wrote:
> If an error is encountered in mdio_mux_init(), the error path will call
> mdiobus_free().  Since mdiobus_register() has been called prior to
> mdio_mux_init(), the bus->state will not be MDIOBUS_UNREGISTERED.  This
> causes a BUG_ON() in mdiobus_free().  To correct this issue, add an
> error path for mdio_mux_init() which calls mdiobus_unregister() prior to
> mdiobus_free().
> 
> Signed-off-by: Jon Mason <jon.mason@broadcom.com>
> Fixes: 98bc865a1ec8 ("net: mdio-mux: Add MDIO mux driver for iProc SoCs")

Acked-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
