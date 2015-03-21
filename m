From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] cx82310_eth: wait for firmware to become ready
Date: Sat, 21 Mar 2015 18:23:45 -0400 (EDT)
Message-ID: <20150321.182345.1891615286035745676.davem@davemloft.net>
References: <1426933777-19260-1-git-send-email-linux@rainbow-software.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: linux@rainbow-software.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1426933777-19260-1-git-send-email-linux@rainbow-software.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ondrej Zary <linux@rainbow-software.org>
Date: Sat, 21 Mar 2015 11:29:37 +0100

> When the device is powered up, some (older) firmware versions fail to work
> properly if we send commands before the boot is complete (everything is OK
> when the device is hot-plugged). The firmware indicates its ready status by
> putting the link up.
> Newer firmwares delay the first command so they don't suffer from this problem.
> They also report the link being always up.
> 
> Wait for firmware to become ready (link up) before sending any commands and/or
> data.
> 
> This also allows lowering CMD_TIMEOUT value to a reasonable time.
> 
> Tested with 4.1.0.9 (old) and 4.1.0.30 (new) firmware versions.
> 
> Signed-off-by: Ondrej Zary <linux@rainbow-software.org>

Applied, thanks.
