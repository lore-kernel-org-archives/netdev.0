From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH] net: phy: Fix mask value write on gmii2rgmii converter
 speed register.
Date: Thu, 14 Sep 2017 16:34:54 +0200
Message-ID: <20170914143454.GB27601@lunn.ch>
References: <1505373391-18697-1-git-send-email-fahad.kunnathadi@dexceldesigns.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, netdev@vger.kernel.org, michal.simek@xilinx.com,
 linux-kernel@vger.kernel.org, soren.brinkmann@xilinx.com,
 linux-arm-kernel@lists.infradead.org
To: Fahad Kunnathadi <fahad.kunnathadi@dexceldesigns.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
Content-Disposition: inline
In-Reply-To: <1505373391-18697-1-git-send-email-fahad.kunnathadi@dexceldesigns.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

On Thu, Sep 14, 2017 at 12:46:31PM +0530, Fahad Kunnathadi wrote:
> To clear Speed Selection in MDIO control register(0x10),
> ie, clear bits 6 and 13 to zero while keeping other bits same.
> Before AND operation,The Mask value has to be perform with bitwise NOT
> operation (ie, ~ operator)
> 
> This patch clears current speed selection before writing the
> new speed settings to gmii2rgmii converter

Hi Fahad

I expect you will find other issues with this driver. I pointed some
out at the time it is submitted, but the developers went quiet as soon
as it was accepted.

Anyway, please ensure David Miller <davem@davemloft.net> gets a copy.

The subject line should be:

[PATCH net] net: phy: Fix mask value write on gmii2rgmii converter speed register.

and include a fixes tag:

Fixes: f411a6160bd4 ("net: phy: Add gmiitorgmii converter support")

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
