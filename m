From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/smsc911x: Add minimal runtime PM support
Date: Mon, 24 Nov 2014 16:42:04 -0500 (EST)
Message-ID: <20141124.164204.382324382412456341.davem@davemloft.net>
References: <1416855497-6479-1-git-send-email-geert+renesas@glider.be>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: steve.glendinning@shawell.net, netdev@vger.kernel.org,
	linux-pm@vger.kernel.org, linux-sh@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: geert+renesas@glider.be
Return-path: <linux-pm-owner@vger.kernel.org>
In-Reply-To: <1416855497-6479-1-git-send-email-geert+renesas@glider.be>
Sender: linux-pm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Geert Uytterhoeven <geert+renesas@glider.be>
Date: Mon, 24 Nov 2014 19:58:17 +0100

> Add minimal runtime PM support (enable on probe, disable on remove), to
> ensure proper operation with a parent device that uses runtime PM.
> 
> This is needed on systems where the external bus controller module of
> the SoC is contained in a PM domain and/or has a gateable functional
> clock. In such cases, before accessing any device connected to the
> external bus, the PM domain must be powered up, and/or the functional
> clock must be enabled, which is typically handled through runtime PM by
> the bus controller driver.
> 
> An example of this is the kzm9g development board, where an smsc9220
> Ethernet controller is connected to the Bus State Controller (BSC) of a
> Renesas sh73a0 SoC.
> 
> Signed-off-by: Geert Uytterhoeven <geert+renesas@glider.be>

Applied to net-next, thanks!
