From: Mark Rutland <mark.rutland@arm.com>
Subject: Re: [PATCH V8 1/7] sxgbe: Add device-tree binding support document
Date: Fri, 21 Mar 2014 11:02:12 +0000
Message-ID: <20140321110212.GM23372@e106331-lin.cambridge.arm.com>
References: <012e01cf4461$79852880$6c8f7980$@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "'netdev'" <netdev@vger.kernel.org>,
	"linux-samsung-soc@vger.kernel.org"
	<linux-samsung-soc@vger.kernel.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	"'David Miller'" <davem@davemloft.net>,
	"'GIRISH K S'" <ks.giri@samsung.com>,
	"'SIVAREDDY KALLAM'" <siva.kallam@samsung.com>,
	"'Vipul Chandrakant'" <vipul.pandya@samsung.com>,
	"'Ilho Lee'" <ilho215.lee@samsung.com>
To: Byungho An <bh74.an@samsung.com>
Return-path: <linux-samsung-soc-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <012e01cf4461$79852880$6c8f7980$@samsung.com>
Sender: linux-samsung-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> +Example:
> +
> +	aliases {
> +		ethernet0 = <&sxgbe0>;
> +	};
> +
> +	sxgbe0: ethernet@1a040000 {
> +		compatible = "samsung,sxgbe-v2.0a";
> +		reg = <0 0x1a040000 0 0x10000>;
> +		interrupt-parent = <&gic>;
> +		interrupts = <0 209 4>, <0 185 4>, <0 186 4>, <0 187 4>,
> +			     <0 188 4>, <0 189 4>, <0 190 4>, <0 191 4>,
> +			     <0 192 4>, <0 193 4>, <0 194 4>, <0 195 4>,
> +			     <0 196 4>, <0 197 4>, <0 198 4>, <0 199 4>,
> +			     <0 200 4>, <0 201 4>, <0 202 4>, <0 203 4>,
> +			     <0 204 4>, <0 205 4>, <0 206 4>, <0 207 4>,
> +			     <0 208 4>, <0 210 4>;
> +		samsung,pbl = <0x08>
> +		samsung,burst-map = <0x20>
> +		samsung,adv-addr-mode = "true"
> +		samsung,force-sf-dma-mode = "true"

You don't need these strings for boolean properties. Their presence of
the property alone (even in the absende of a value) is sufficient. These
should simply be:

	samsung,adv-addr-map;
	samsung,force-sf-dma-mode;

It is still an open question as to whether these properties are
necessary.

Cheers,
Mark.
