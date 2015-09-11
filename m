From: =?utf-8?B?U8O2cmVu?= Brinkmann <soren.brinkmann@xilinx.com>
Subject: Re: [RFC PATCH 3/3] devicetree: macb: Add optional property tsu-clk
Date: Fri, 11 Sep 2015 09:52:56 -0700
Message-ID: <20150911165256.GT19678@xsjsorenbubuntu>
References: <1441958258-35441-1-git-send-email-harinik@xilinx.com>
 <1441958258-35441-4-git-send-email-harinik@xilinx.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <nicolas.ferre@atmel.com>, <davem@davemloft.net>,
	<robh+dt@kernel.org>, <pawel.moll@arm.com>, <mark.rutland@arm.com>,
	<ijc+devicetree@hellion.org.uk>, <galak@codeaurora.org>,
	<boris.brezillon@free-electrons.com>,
	<alexandre.belloni@free-electrons.com>,
	<harinikatakamlinux@gmail.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <devicetree@vger.kernel.org>,
	<harinik@xilinx.com>, <punnaia@xilinx.com>, <michals@xilinx.com>,
	<anirudh@xilinx.com>
To: Harini Katakam <harini.katakam@xilinx.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1441958258-35441-4-git-send-email-harinik@xilinx.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Harini,

On Fri, 2015-09-11 at 01:27PM +0530, Harini Katakam wrote:
> Add TSU clock frequency to be used for 1588 support in macb driver.
>=20
> Signed-off-by: Harini Katakam <harinik@xilinx.com>
> ---
>  Documentation/devicetree/bindings/net/macb.txt |    3 +++
>  1 file changed, 3 insertions(+)
>=20
> diff --git a/Documentation/devicetree/bindings/net/macb.txt b/Documen=
tation/devicetree/bindings/net/macb.txt
> index b5d7976..f7c0ea8 100644
> --- a/Documentation/devicetree/bindings/net/macb.txt
> +++ b/Documentation/devicetree/bindings/net/macb.txt
> @@ -19,6 +19,9 @@ Required properties:
>  	Optional elements: 'tx_clk'
>  - clocks: Phandles to input clocks.
> =20
> +Optional properties:
> +- tsu-clk: Time stamp unit clock frequency used.

Why are we not using the CCF and a clk_get_rate() in the driver?

	S=C3=B6ren
