From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH V4 1/1] net: ethernet: Add TSE PCS support to dwmac-socfpga
Date: Tue, 21 Jun 2016 11:34:49 +0200
Message-ID: <3759495.N5GR8CgQvA@wuerfel>
References: <1466498771-18971-1-git-send-email-thloh@altera.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: robh+dt@kernel.org, mark.rutland@arm.com, peppe.cavallaro@st.com,
	alexandre.torgue@st.com, davem@davemloft.net,
	preid@electromag.com.au, dinguyen@opensource.altera.com,
	netdev@vger.kernel.org, devicetree@vger.kernel.org,
	linux-kernel@vger.kernel.org, thloh85@gmail.com, cnphoon@altera.com
To: thloh@altera.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1466498771-18971-1-git-send-email-thloh@altera.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday, June 21, 2016 1:46:11 AM CEST thloh@altera.com wrote:
> diff --git a/Documentation/devicetree/bindings/net/socfpga-dwmac.txt b/Documentation/devicetree/bindings/net/socfpga-dwmac.txt
> index 72d82d6..dd10f2f 100644
> --- a/Documentation/devicetree/bindings/net/socfpga-dwmac.txt
> +++ b/Documentation/devicetree/bindings/net/socfpga-dwmac.txt
> @@ -17,9 +17,26 @@ Required properties:
>  Optional properties:
>  altr,emac-splitter: Should be the phandle to the emac splitter soft IP node if
>  		DWMAC controller is connected emac splitter.
> +phy-mode: The phy mode the ethernet operates in
> +altr,sgmii_to_sgmii_converter: phandle to the TSE SGMII converter
> +

Please use '-' instead of '_' in the property names.

Can you explain in the patch description why you can't reference
the converter using the normal "phy-handle" property and implement
the converter as a phy driver?

	Arnd
