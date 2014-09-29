From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net: stmmac: fix stmmac_pci_probe failed when
 CONFIG_HAVE_CLK is selected
Date: Mon, 29 Sep 2014 16:37:20 -0400 (EDT)
Message-ID: <20140929.163720.1059434932375001698.davem@davemloft.net>
References: <1411738975-20056-1-git-send-email-hock.leong.kweh@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, rayagond@vayavyalabs.com,
	vbridgers2013@gmail.com, wens@csie.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, boon.leong.ong@intel.com,
	tobias.johannes.klausmann@mni.thm.de
To: hock.leong.kweh@intel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1411738975-20056-1-git-send-email-hock.leong.kweh@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Kweh Hock Leong <hock.leong.kweh@intel.com>
Date: Fri, 26 Sep 2014 21:42:55 +0800

> From: "Kweh, Hock Leong" <hock.leong.kweh@intel.com>
> 
> When the CONFIG_HAVE_CLK is selected for the system, the stmmac_pci_probe
> will fail with dmesg:
> [    2.167225] stmmaceth 0000:00:14.6: enabling device (0000 -> 0002)
> [    2.178267] stmmaceth 0000:00:14.6: enabling bus mastering
> [    2.178436] stmmaceth 0000:00:14.6: irq 24 for MSI/MSI-X
> [    2.178703] stmmaceth 0000:00:14.6: stmmac_dvr_probe: warning: cannot
> get CSR clock
> [    2.186503] stmmac_pci_probe: main driver probe failed
> [    2.194003] stmmaceth 0000:00:14.6: disabling bus mastering
> [    2.196473] stmmaceth: probe of 0000:00:14.6 failed with error -2
> 
> This patch fix the issue by breaking the dependency to devm_clk_get()
> as the CSR clock can be obtained at priv->plat->clk_csr from pci driver.
> 
> Reported-by: Tobias Klausmann <tobias.johannes.klausmann@mni.thm.de>
> Signed-off-by: Kweh, Hock Leong <hock.leong.kweh@intel.com>

Applied, thank you.
