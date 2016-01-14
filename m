From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [PATCH] ssb: host_soc depends on sprom
Date: Thu, 14 Jan 2016 08:46:29 +0200
Message-ID: <8760ywd5fe.fsf@kamboji.qca.qualcomm.com>
References: <8128014.DbbgBtKY3z@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: =?utf-8?Q?Rafa=C5=82_Mi=C5=82ecki?= <zajec5@gmail.com>,
	Hauke Mehrtens <hauke@hauke-m.de>, Michael Buesch <m@bues.ch>,
	linux-mips@linux-mips.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <8128014.DbbgBtKY3z@wuerfel> (Arnd Bergmann's message of "Wed, 13
	Jan 2016 23:51:43 +0100")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Arnd Bergmann <arnd@arndb.de> writes:

> Drivers that use the SSB sprom functionality typically 'select SSB_SPROM'
> from Kconfig, but CONFIG_SSB_HOST_SOC misses this, which results in
> a build failure unless at least one of the other drivers that selects
> it is enabled:
>
> drivers/built-in.o: In function `ssb_host_soc_get_invariants':
> (.text+0x459494): undefined reference to `ssb_fill_sprom_with_fallback'
>
> This adds the same select statement that is used elsewhere.
>
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> Fixes: 541c9a84cd85 ("ssb: pick SoC invariants code from MIPS BCM47xx arch")
> ---
> I'm not sure who the right person is to pick up the fix. The patch that
> introduced the problem was merged by Kalle through the iwlwifi tree.

I can take it. For historical reasons ssb patches go through my
wireless-drivers trees.

-- 
Kalle Valo
