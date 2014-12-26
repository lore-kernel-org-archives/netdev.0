From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: phy: micrel: use generic config_init for
 KSZ8021/KSZ8031
Date: Fri, 26 Dec 2014 16:24:03 -0500 (EST)
Message-ID: <20141226.162403.158022430903367528.davem@davemloft.net>
References: <1419335957-18020-1-git-send-email-johan@kernel.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, bth@kamstrup.dk
To: johan@kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1419335957-18020-1-git-send-email-johan@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Johan Hovold <johan@kernel.org>
Date: Tue, 23 Dec 2014 12:59:17 +0100

> Use generic config_init callback also for KSZ8021 and KSZ8031.
> 
> This has been avoided this far due to commit b838b4aced99 ("phy/micrel:
> KSZ8031RNL RMII clock reconfiguration bug"), which claims that the PHY
> becomes unresponsive if the broadcast-disable flag is set before
> configuring the clock mode.
> 
> Turns out that the problem seemingly worked-around by the above
> mentioned commit was really due to a hardware-configuration issue, where
> the PHY was in fact strapped to address 3 rather than 0.
> 
> Tested-by: Bruno Thomsen <bth@kamstrup.dk>
> Signed-off-by: Johan Hovold <johan@kernel.org>

Applied, thank you.
