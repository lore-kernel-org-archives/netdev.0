From: Rob Herring <robh@kernel.org>
Subject: Re: [PATCH V3] net: mediatek: update the IRQ part of the binding
 document
Date: Wed, 13 Apr 2016 12:33:35 -0500
Message-ID: <20160413173335.GA15022@rob-hp-laptop>
References: <1460442918-6070-1-git-send-email-blogic@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Felix Fietkau <nbd@openwrt.org>,
	Matthias Brugger <matthias.bgg@gmail.com>,
	netdev@vger.kernel.org, linux-mediatek@lists.infradead.org,
	linux-kernel@vger.kernel.org, devicetree@vger.kernel.org
To: John Crispin <blogic@openwrt.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1460442918-6070-1-git-send-email-blogic@openwrt.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Apr 12, 2016 at 08:35:18AM +0200, John Crispin wrote:
> The current binding document only describes a single interrupt. Update the
> document by adding the 2 other interrupts.
> 
> The driver currently only uses a single interrupt. The HW is however able
> to using IRQ grouping to split TX and RX onto separate GIC irqs.
> 
> Signed-off-by: John Crispin <blogic@openwrt.org>
> Cc: devicetree@vger.kernel.org
> ---
> This binding doc was merged in 4.6-rc1 and there are no users yet. The
> current driver only uses 1 irq but will work fine with all 3 listed in
> the devicetree. This patch should be merged before v4.6 is final such
> that listing all 3 irqs becomes part of the ABI. I have already posted
> a patch that utilizes all 3 irqs for next-next for v4.7 inclusion.
> 
> Changes in V3:
> * be verbose about the 3 irqs and their ordering
> 
> Changes in V2:
> * split this patch out of the series that fixes tx stalls in the driver
> 
>  Documentation/devicetree/bindings/net/mediatek-net.txt |    7 +++++--
>  1 file changed, 5 insertions(+), 2 deletions(-)

Acked-by: Rob Herring <robh@kernel.org>
