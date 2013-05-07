From: Valentin Longchamp <valentin.longchamp@keymile.com>
Subject: Re: [PATCH 0/7] mv643xx_eth: device tree bindings
Date: Tue, 07 May 2013 11:10:24 +0200
Message-ID: <5188C500.8010209@keymile.com>
References: <1365071235-11611-1-git-send-email-florian@openwrt.org>
 <1367854420-8006-1-git-send-email-sebastian.hesselbarth@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jason Cooper <jason@lakedaemon.net>, linux-doc@vger.kernel.org,
 netdev@vger.kernel.org, devicetree-discuss@lists.ozlabs.org,
 linux-kernel@vger.kernel.org,
 "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>
To: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1367854420-8006-1-git-send-email-sebastian.hesselbarth@gmail.com>
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

Sebastian,

On 05/06/2013 05:33 PM, Sebastian Hesselbarth wrote:
> This patch set picks up work by Florian Fainelli bringing full DT
> support to mv643xx_eth and Marvell SoCs using it.
> 
> The current patch set drops Florian's device tree conversions for
> Kirkwood, Dove, and Orion5x in favour of split patches for board
> files and board descriptor files.
> 
> Device tree conversion for Dove and Kirkwood is added. Dove has
> been fully tested, while Kirkwood is compile-tested only.
> 
> Florian Fainelli (2):
>   net: mv643xx_eth: add Device Tree bindings
>   net: mv643xx_eth: update Device Tree bindings documentation
> 
> Sebastian Hesselbarth (5):
>   ARM: dove: remove legacy mv643xx_eth setup
>   ARM: dove: add gigabit ethernet and mvmdio device tree nodes
>   ARM: kirkwood: remove legacy mv643xx_eth board setup
>   ARM: kirkwood: add gigabit ethernet and mvmdio device tree nodes
>   ARM: kirkwood: remove legacy clk alias for mv643xx_eth
> 

I have successfully tested these patches on km_kirkwood, you can add my tested-by:

Tested-by: Valentin Longchamp<valentin.longchamp@keymile.com>
