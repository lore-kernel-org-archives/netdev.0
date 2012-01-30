From: Greg KH <gregkh@suse.de>
Subject: Re: [01/22] Cyclades PC300 driver: merge in Cyclades driver version
 4.1.0
Date: Mon, 30 Jan 2012 06:37:08 -0800
Message-ID: <20120130143708.GB13388@suse.de>
References: <20120130024354.GB10262@cronus.persephoneslair.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	khc@pm.waw.pl, davem@davemloft.net, mmarek@suse.cz,
	jkosina@suse.cz, joe@perches.com, justinmattock@gmail.com,
	alan@linux.intel.com, jdmason@kudzu.us
To: Andrea Shepard <andrea@persephoneslair.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20120130024354.GB10262@cronus.persephoneslair.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Jan 29, 2012 at 06:43:54PM -0800, Andrea Shepard wrote:
>  struct RUNTIME_9050 {
> -	u32 loc_addr_range[4];	/* 00-0Ch : Local Address Ranges */
> -	u32 loc_rom_range;	/* 10h : Local ROM Range */
> -	u32 loc_addr_base[4];	/* 14-20h : Local Address Base Addrs */
> -	u32 loc_rom_base;	/* 24h : Local ROM Base */
> -	u32 loc_bus_descr[4];	/* 28-34h : Local Bus Descriptors */
> -	u32 rom_bus_descr;	/* 38h : ROM Bus Descriptor */
> -	u32 cs_base[4];		/* 3C-48h : Chip Select Base Addrs */
> -	u32 intr_ctrl_stat;	/* 4Ch : Interrupt Control/Status */
> -	u32 init_ctrl;		/* 50h : EEPROM ctrl, Init Ctrl, etc */
> +	uclong	loc_addr_range[4];	/* 00-0Ch : Local Address Ranges */
> +	uclong	loc_rom_range;		/* 10h : Local ROM Range */
> +	uclong	loc_addr_base[4];	/* 14-20h : Local Address Base Addrs */
> +	uclong	loc_rom_base;		/* 24h : Local ROM Base */
> +	uclong	loc_bus_descr[4];	/* 28-34h : Local Bus Descriptors */
> +	uclong	rom_bus_descr;		/* 38h : ROM Bus Descriptor */
> +	uclong	cs_base[4];		/* 3C-48h : Chip Select Base Addrs */
> +	uclong	intr_ctrl_stat;		/* 4Ch : Interrupt Control/Status */
> +	uclong	init_ctrl;		/* 50h : EEPROM ctrl, Init Ctrl, etc */

Now I'm not the network driver maintainer, so he might take this type of
thing, but I sure wouldn't.

I understand your want to dump the updated version of the driver in, and
then clean it up, but come on, allowing changes like this, that you can
see are obviously wrong (same goes for the return lines), and then
cleaning it up (hopefully) later on?

You can edit the diff by hand to remove this type of thing, so the churn
for it is not needed at all, which makes your overall diff smaller and
series easier to read and understand.

but that's just my opinion...

greg k-h
