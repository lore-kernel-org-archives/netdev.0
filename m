From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [RESEND^2] ssb: mark ssb_bus_register as __maybe_unused
Date: Tue, 19 Jan 2016 19:26:25 +0000 (UTC)
Message-ID: <20160119192625.4E3F960577@smtp.codeaurora.org>
References: <6063400.39vor3soEb@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-arm-kernel@lists.infradead.org, linux-mips@linux-mips.org,
        Hauke Mehrtens <hauke@hauke-m.de>,
        =?utf-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>,
        linux-kernel@vger.kernel.org, Michael Buesch <m@bues.ch>,
        netdev@vger.kernel.org, linux-wireless@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-mips-bounce@linux-mips.org>
In-Reply-To: <6063400.39vor3soEb@wuerfel>
Sender: linux-mips-bounce@linux-mips.org
Errors-to: linux-mips-bounce@linux-mips.org
List-help: <mailto:ecartis@linux-mips.org?Subject=help>
List-unsubscribe: <mailto:ecartis@linux-mips.org?subject=unsubscribe%20linux-mips>
List-software: Ecartis version 1.0.0
List-subscribe: <mailto:ecartis@linux-mips.org?subject=subscribe%20linux-mips>
List-owner: <mailto:ralf@linux-mips.org>
List-post: <mailto:linux-mips@linux-mips.org>
List-archive: <http://www.linux-mips.org/archives/linux-mips/>
List-Id: netdev.vger.kernel.org


> The SoC variant of the ssb code is now optional like the other
> ones, which means we can build the framwork without any
> front-end, but that results in a warning:
> 
> drivers/ssb/main.c:616:12: warning: 'ssb_bus_register' defined but not used [-Wunused-function]
> 
> This annotates the ssb_bus_register function as __maybe_unused to
> shut up the warning. A configuration like this will not work on
> any hardware of course, but we still want this to silently build
> without warnings if the configuration is allowed in the first
> place.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> Fixes: 845da6e58e19 ("ssb: add Kconfig entry for compiling SoC related code")
> Acked-by: Michael Buesch <m@bues.ch>

Thanks, applied to wireless-drivers.git.

Kalle Valo
