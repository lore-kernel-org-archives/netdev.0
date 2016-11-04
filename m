From: Jon Mason <jon.mason@broadcom.com>
Subject: Re: [PATCH v6 7/7] arm64: dts: NS2: add AMAC ethernet support
Date: Fri, 4 Nov 2016 12:30:25 -0400
Message-ID: <20161104163024.GA6128@broadcom.com>
References: <1478236262-3351-1-git-send-email-jon.mason@broadcom.com>
 <1478236262-3351-8-git-send-email-jon.mason@broadcom.com>
 <69ecd9b9-d495-9dfa-ad26-4fa622d951a0@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
        Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>,
        Florian Fainelli <f.fainelli@gmail.com>, rafal@milecki.pl,
        bcm-kernel-feedback-list@broadcom.com, netdev@vger.kernel.org,
        devicetree@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <69ecd9b9-d495-9dfa-ad26-4fa622d951a0@cogentembedded.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Nov 04, 2016 at 04:31:40PM +0300, Sergei Shtylyov wrote:
> Hello.
> 
> On 11/4/2016 8:11 AM, Jon Mason wrote:
> 
> >Add support for the AMAC ethernet to the Broadcom Northstar2 SoC device
> >tree
> >
> >Signed-off-by: Jon Mason <jon.mason@broadcom.com>
> >---
> > arch/arm64/boot/dts/broadcom/ns2-svk.dts |  5 +++++
> > arch/arm64/boot/dts/broadcom/ns2.dtsi    | 12 ++++++++++++
> > 2 files changed, 17 insertions(+)
> >
> >diff --git a/arch/arm64/boot/dts/broadcom/ns2-svk.dts b/arch/arm64/boot/dts/broadcom/ns2-svk.dts
> >index b09f3bc..c4d5442 100644
> >--- a/arch/arm64/boot/dts/broadcom/ns2-svk.dts
> >+++ b/arch/arm64/boot/dts/broadcom/ns2-svk.dts
> >@@ -56,6 +56,10 @@
> > 	};
> > };
> >
> >+&enet {
> >+	status = "ok";
> 
>    The spec dictates it should be "okay" (although "ok" is also recognized).

The rest of the file uses "ok".  So, the addition above is consistent
with the other entries.

Perhaps a patch outside this series to convert the entire file from
"ok" to "okay" would be acceptable to you.

Thanks,
Jon

> 
> >+};
> >+
> > &pci_phy0 {
> > 	status = "ok";
> > };
> >@@ -174,6 +178,7 @@
> > &mdio_mux_iproc {
> > 	mdio@10 {
> > 		gphy0: eth-phy@10 {
> >+			enet-phy-lane-swap;
> > 			reg = <0x10>;
> > 		};
> > 	};
> [...]
> 
> MBR, Sergei
> 
