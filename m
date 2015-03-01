From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sh_eth: Fix lost MAC address on kexec
Date: Sun, 01 Mar 2015 00:28:47 -0500 (EST)
Message-ID: <20150301.002847.261300841277182822.davem@davemloft.net>
References: <1425053786-24223-1-git-send-email-geert+renesas@glider.be>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ben.hutchings@codethink.co.uk, nobuhiro.iwamatsu.yj@renesas.com,
	horms@verge.net.au, magnus.damm@gmail.com, khilman@kernel.org,
	netdev@vger.kernel.org, linux-sh@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: geert+renesas@glider.be
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <1425053786-24223-1-git-send-email-geert+renesas@glider.be>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Geert Uytterhoeven <geert+renesas@glider.be>
Date: Fri, 27 Feb 2015 17:16:26 +0100

> Commit 740c7f31c094703c ("sh_eth: Ensure DMA engines are stopped before
> freeing buffers") added a call to sh_eth_reset() to the
> sh_eth_set_ringparam() and sh_eth_close() paths.
> 
> However, setting the software reset bit(s) in the EDMR register resets
> the MAC Address Registers to zero. Hence after kexec, the new kernel
> doesn't detect a valid MAC address and assigns a random MAC address,
> breaking DHCP.
> 
> Set the MAC address again after the reset in sh_eth_dev_exit() to fix
> this.
> 
> Tested on r8a7740/armadillo (GETHER) and r8a7791/koelsch (FAST_RCAR).
> 
> Fixes: 740c7f31c094703c ("sh_eth: Ensure DMA engines are stopped before freeing buffers")
> Signed-off-by: Geert Uytterhoeven <geert+renesas@glider.be>

Applied.
