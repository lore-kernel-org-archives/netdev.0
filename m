From: Alexey Brodkin <Alexey.Brodkin@synopsys.com>
Subject: Re: [PATCH] ARC: axs10x - add Ethernet PHY description in .dts
Date: Tue, 15 Mar 2016 14:50:02 +0000
Message-ID: <1458053402.4174.12.camel@synopsys.com>
References: <1458034150-10766-1-git-send-email-abrodkin@synopsys.com>
	 <56E81E66.6080706@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-7"
Content-Transfer-Encoding: 8BIT
Cc: "robh@kernel.org" <robh@kernel.org>,
	"preid@electromag.com.au" <preid@electromag.com.au>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-snps-arc@lists.infradead.org"
	<linux-snps-arc@lists.infradead.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "sergei.shtylyov@cogentembedded.com"
	<sergei.shtylyov@cogentembedded.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <56E81E66.6080706@cogentembedded.com>
Content-Language: en-US
Content-ID: <2B818A4BE41499428BBD420E400A94A9@internal.synopsys.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Sergei,

On Tue, 2016-03-15 at 17:38 +-0300, Sergei Shtylyov wrote:
+AD4- Hello.
+AD4- 
+AD4- On 3/15/2016 12:29 PM, Alexey Brodkin wrote:
+AD4- 
+AD4- +AD4- 
+AD4- +AD4- Following commit broke DW GMAC functionality on AXS10x boards:
+AD4- +AD4- http://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id+AD0-e34d65696d2ef13dc32f2a162556c86c461ed763
+AD4- +AD4- 
+AD4- +AD4- That's what happens on eth0 up:
+AD4- +AD4- ---------------------------+AD4-8------------------------
+AD4- +AD4- libphy: PHY stmmac-0:ffffffff not found
+AD4- +AD4- eth0: Could not attach to PHY
+AD4- +AD4- stmmac+AF8-open: Cannot attach to PHY (error: -19)
+AD4- +AD4- ---------------------------+AD4-8------------------------
+AD4- +AD4- 
+AD4- +AD4- Simplest solution is to add PHY description in board's .dts.
+AD4- +AD4- And so we do here.
+AD4- +AD4- 
+AD4- +AD4- Signed-off-by: Alexey Brodkin +ADw-abrodkin+AEA-synopsys.com+AD4-
+AD4- +AD4- Cc: Rob Herring +ADw-robh+AEA-kernel.org+AD4-
+AD4- +AD4- Cc: Phil Reid +ADw-preid+AEA-electromag.com.au+AD4-
+AD4- +AD4- Cc: David S. Miller +ADw-davem+AEA-davemloft.net+AD4-
+AD4- +AD4- Cc: linux-kernel+AEA-vger.kernel.org
+AD4- +AD4- Cc: netdev+AEA-vger.kernel.org
+AD4- +AD4- Cc: stable+AEA-vger.kernel.org +ACM- 4.5.x
+AD4- +AD4- ---
+AD4- +AD4- +AKA- arch/arc/boot/dts/axs10x+AF8-mb.dtsi +AHw- 8 +-+-+-+-+-+-+-+-
+AD4- +AD4- +AKA- 1 file changed, 8 insertions(+-)
+AD4- +AD4- 
+AD4- +AD4- diff --git a/arch/arc/boot/dts/axs10x+AF8-mb.dtsi b/arch/arc/boot/dts/axs10x+AF8-mb.dtsi
+AD4- +AD4- index 44a578c..04b999e 100644
+AD4- +AD4- --- a/arch/arc/boot/dts/axs10x+AF8-mb.dtsi
+AD4- +AD4- +-+-+- b/arch/arc/boot/dts/axs10x+AF8-mb.dtsi
+AD4- +AD4- +AEAAQA- -47,6 +-47,14 +AEAAQA-
+AD4- +AD4- +AKAAoA-			clocks +AD0- +ADwAJg-apbclk+AD4AOw-
+AD4- +AD4- +AKAAoA-			clock-names +AD0- +ACI-stmmaceth+ACIAOw-
+AD4- +AD4- +AKAAoA-			max-speed +AD0- +ADw-100+AD4AOw-
+AD4- +AD4- +-			mdio0 +AHs-
+AD4- +AD4- +-				+ACM-address-cells +AD0- +ADw-1+AD4AOw-
+AD4- +AD4- +-				+ACM-size-cells +AD0- +ADw-0+AD4AOw-
+AD4- +AD4- +-				compatible +AD0- +ACI-snps,dwmac-mdio+ACIAOw-
+AD4- +AD4- +-				phy0: ethernet-phy+AEA-0 +AHs-
+AD4- +AKAAoACgAKA-The naming is inconsistent with the +ACI-reg+ACI- prop specified, should be +AEA-1.

Makes sense.
Will re-send it with mentioned fix.

-Alexey
