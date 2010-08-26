From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] Gigabit Ethernet driver of Topcliff PCH
Date: Thu, 26 Aug 2010 08:43:12 -0700
Message-ID: <20100826084312.2b23048f@nehalam>
References: <4C763A67.5040107@dsn.okisemi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
	ML netdev <netdev@vger.kernel.org>,
	Greg Rose <gregory.v.rose@intel.com>,
	Maxime Bizon <mbizon@freebox.fr>,
	Kristoffer Glembo <kristoffer@gaisler.com>,
	Ralf Baechle <ralf@linux-mips.org>,
	John Linn <john.linn@xilinx.com>,
	Randy Dunlap <randy.dunlap@oracle.com>,
	"David S. Miller" <davem@davemloft.net>,
	MeeGo <meego-dev@meego.com>, "Wang, Qi" <qi.wang@intel.com>,
	"Wang, Yong Y" <yong.y.wang@intel.com>,
	Andrew <andrew.chih.howe.khor@intel.com>,
	Intel OTC <joel.clark@intel.com>,
	"Foster, Margie" <margie.foster@intel.com>,
	Toshiharu Okada <okada533@dsn.okisemi.com>,
	Tomoya Morinaga <morinaga526@dsn.okisemi.com>,
	Takahiro Shimizu <shimizu394@dsn.okisemi.com>
To: Masayuki Ohtake <masa-korg@dsn.okisemi.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4C763A67.5040107@dsn.okisemi.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 26 Aug 2010 18:56:55 +0900
Masayuki Ohtake <masa-korg@dsn.okisemi.com> wrote:

> s32 pch_gbe_mac_read_mac_addr(struct pch_gbe_hw *hw)
> +{
> +	u32  adr1a, adr1b;
> +
> +	PCH_GBE_DEBUG("pch_gbe_mac_read_mac_addr\n");
> +
> +	adr1a = ioread32(&hw->reg->mac_adr[0].high);
> +	adr1b = ioread32(&hw->reg->mac_adr[0].low);
> +
> +	hw->mac.addr[0] = (u8)(adr1a & 0xFF);
> +	hw->mac.addr[1] = (u8)((adr1a >> 8) & 0xFF);
> +	hw->mac.addr[2] = (u8)((adr1a >> 16) & 0xFF);
> +	hw->mac.addr[3] = (u8)((adr1a >> 24) & 0xFF);
> +	hw->mac.addr[4] = (u8)(adr1b & 0xFF);
> +	hw->mac.addr[5] = (u8)((adr1b >> 8) & 0xFF);
> +
> +	PCH_GBE_DEBUG("hw->mac.addr : 0x%02x %02x %02x %02x %02x %02x\n",
> +		hw->mac.addr[0], hw->mac.addr[1], hw->mac.addr[2],
> +		hw->mac.addr[3], hw->mac.addr[4], hw->mac.addr[5]);

can use new %pM printk format here.
