From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: Re: [PATCH 4/4] net: mvneta: update clocks property and document
 additional clock-names
Date: Wed, 20 Jan 2016 10:07:26 +0100
Message-ID: <20160120100726.46dc8816@free-electrons.com>
References: <1453277183-5412-1-git-send-email-jszhang@marvell.com>
 <1453277183-5412-5-git-send-email-jszhang@marvell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: mark.rutland@arm.com, devicetree@vger.kernel.org, pawel.moll@arm.com,
 ijc+devicetree@hellion.org.uk, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org, robh+dt@kernel.org, galak@codeaurora.org,
 mw@semihalf.com, davem@davemloft.net, linux-arm-kernel@lists.infradead.org,
 sebastian.hesselbarth@gmail.com
To: Jisheng Zhang <jszhang@marvell.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1453277183-5412-5-git-send-email-jszhang@marvell.com>
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

Dear Jisheng Zhang,

On Wed, 20 Jan 2016 16:06:23 +0800, Jisheng Zhang wrote:

> diff --git a/Documentation/devicetree/bindings/net/marvell-armada-370-neta.txt b/Documentation/devicetree/bindings/net/marvell-armada-370-neta.txt
> index aeea50c..f85b93b 100644
> --- a/Documentation/devicetree/bindings/net/marvell-armada-370-neta.txt
> +++ b/Documentation/devicetree/bindings/net/marvell-armada-370-neta.txt
> @@ -6,12 +6,16 @@ Required properties:
>  - interrupts: interrupt for the device
>  - phy: See ethernet.txt file in the same directory.
>  - phy-mode: See ethernet.txt file in the same directory
> -- clocks: a pointer to the reference clock for this device.
> +- clocks: Array of clocks required for this device; requires at least one
> +  for CORE clock.

Rather than "Array", I would say "list", so what about:

 - clocks: List of clocks for this device. At least one clock is
   mandatory for the core clock. If several clocks are given, then the
   clock-names property must be used to identify them.

>  Optional properties:
>  - tx-csum-limit: maximum mtu supported by port that allow TX checksum.
>    Value is presented in bytes. If not used, by default 1600B is set for
>    "marvell,armada-370-neta" and 9800B for others.
> +- clock-names: Array of names corresponding to clocks property; shall be
> +  "core" for CORE clock and "axi" for optional AXI clock.

Array -> List.

Thanks!

Thomas
-- 
Thomas Petazzoni, CTO, Free Electrons
Embedded Linux, Kernel and Android engineering
http://free-electrons.com
