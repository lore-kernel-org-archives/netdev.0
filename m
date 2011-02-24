From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] Network driver for PMC-Sierra MSP71xx TSMAC.
Date: Thu, 24 Feb 2011 09:45:56 -0800
Message-ID: <20110224094556.6c371c38@nehalam>
References: <1298548660-10546-1-git-send-email-anoop.pa@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, khilman@deeprootsystems.com, cyril@ti.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-mips@linux-mips.org
To: "Anoop P.A" <anoop.pa@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1298548660-10546-1-git-send-email-anoop.pa@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 24 Feb 2011 17:27:40 +0530
"Anoop P.A" <anoop.pa@gmail.com> wrote:

> +#if PMC_MSP_TSMAC
> +
> +config DESC_ALL_DSPRAM
> +	bool "TX/RX Descriptors in DSPRAM"
> +	depends on DMA_TO_SPRAM
> +	default n
> +	help
> +	  Turning this on puts TX/RX descriptors in DSPRAM. Otherwise they are in
> +	  DRAM.
> +
> +config TSMAC_LINELOOPBACK_FEATURE
> +	bool "lineLoopBack command"
> +	default n
> +	help
> +	  Turning this on includes the lineLoopBack command in the driver's proc
> +	  interface.  Echoing 1 into the lineLoopBack results in all rx packets
> +	  being transmitted out the same port.
> +
> +config TSMAC_TEST_CMDS
> +	bool "test commands"
> +	default n
> +	help
> +	  Turning this on includes the testing commands in the driver's proc
> +	  interface.  These are used internally by PMC.
> +

Too many config options. Usually no config options is best, or at
most one debug option.

The proc interface for testing should be replaced with debugfs
