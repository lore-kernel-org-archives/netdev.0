From: Scott Wood <scottwood@freescale.com>
Subject: Re: [PATCH UCC TDM 3/3 ] Modified Documentation to explain dts
	entries for TDM driver
Date: Thu, 24 Jan 2008 14:12:26 -0600
Message-ID: <20080124201226.GA3926@loki.buserror.net>
References: <Pine.LNX.4.64.0801241022070.27491@linux121>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kumar.gala@freescale.com, akpm@linux-foundation.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	rubini@vision.unipv.it, linuxppc-dev@ozlabs.org,
	michael.barkowski@freescale.com, rich.cutler@freescale.com,
	timur@freescale.com, ashish.kalra@freescale.com
To: Poonam_Aggrwal-b10812 <b10812@freescale.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757438AbYAXUNA@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0801241022070.27491@linux121>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jan 24, 2008 at 10:24:13AM +0530, Poonam_Aggrwal-b10812 wrote:
> +  ix) Baud Rate Generator (BRG)
> +
> +  Required properties:
> +  - compatible : shpuld be "fsl,cpm-brg"
> +  - fsl,brg-sources : define the input clock for all 16 BRGs. The input
> +    clock source could be 1 to 24 for CLK1 to CLK24. Zero means that the
> +    particular BRG will be driven by QE clock(BRGCLK).

Should also have a clock-frequency property to specify what BRGCLK is.

-Scott
