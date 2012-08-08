From: Stefan Roese <sr@denx.de>
Subject: Re: [PATCH 07/11] net/stmmac: mark probe function as __devinit
Date: Wed, 08 Aug 2012 17:07:21 +0200
Message-ID: <502280A9.5070009@denx.de>
References: <1344437248-20560-1-git-send-email-arnd@arndb.de> <1344437248-20560-8-git-send-email-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-arm-kernel@lists.infradead.org, arm@kernel.org,
	linux-kernel@vger.kernel.org,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1344437248-20560-8-git-send-email-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/08/2012 04:47 PM, Arnd Bergmann wrote:
> Driver probe functions are generally __devinit so they will be
> discarded after initialization for non-hotplug kernels.
> This was found by a new warning after patch 6a228452d "stmmac: Add
> device-tree support" adds a new __devinit function that is called
> from stmmac_pltfr_probe.
> 
> Without this patch, building socfpga_defconfig results in:
> 
> WARNING: drivers/net/ethernet/stmicro/stmmac/stmmac.o(.text+0x5d4c): Section mismatch in reference from the function stmmac_pltfr_probe() to the function .devinit.text:stmmac_probe_config_dt()
> The function stmmac_pltfr_probe() references
> the function __devinit stmmac_probe_config_dt().
> This is often because stmmac_pltfr_probe lacks a __devinit
> annotation or the annotation of stmmac_probe_config_dt is wrong.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> Cc: Stefan Roese <sr@denx.de>
> Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
> Cc: David S. Miller <davem@davemloft.net>
> Cc: netdev@vger.kernel.org

Acked-by: Stefan Roese <sr@denx.de>

Thanks,
Stefan
