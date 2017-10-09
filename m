From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] cdc_ether: flag the u-blox TOBY-L2 and SARA-U2 as wwan
Date: Mon, 09 Oct 2017 16:03:45 -0700 (PDT)
Message-ID: <20171009.160345.94596657344673183.davem@davemloft.net>
References: <20171009120512.16681-1-aleksander@aleksander.es>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: oliver@neukum.org, marco.demarco@u-blox.com,
        stefano.godeas@u-blox.com, linux-usb@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: aleksander@aleksander.es
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171009120512.16681-1-aleksander@aleksander.es>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Aleksander Morgado <aleksander@aleksander.es>
Date: Mon,  9 Oct 2017 14:05:12 +0200

> The u-blox TOBY-L2 is a LTE Cat 4 module with HSPA+ and 2G fallback.
> This module allows switching to different USB profiles with the
> 'AT+UUSBCONF' command, and provides a ECM network interface when the
> 'AT+UUSBCONF=2' profile is selected.
> 
> The u-blox SARA-U2 is a HSPA module with 2G fallback. The default USB
> configuration includes a ECM network interface.
> 
> Both these modules are controlled via AT commands through one of the
> TTYs exposed. Connecting these modules may be done just by activating
> the desired PDP context with 'AT+CGACT=1,<cid>' and then running DHCP
> on the ECM interface.
> 
> Signed-off-by: Aleksander Morgado <aleksander@aleksander.es>

Applied, thank you.
