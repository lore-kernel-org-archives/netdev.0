From: Ralf Baechle <ralf@linux-mips.org>
Subject: Re: [PATCH 09/13] timer: Remove users of expire and data arguments
 to DEFINE_TIMER
Date: Mon, 9 Oct 2017 15:23:05 +0200
Message-ID: <20171009132305.GH20977@linux-mips.org>
References: <1507159627-127660-1-git-send-email-keescook@chromium.org>
 <1507159627-127660-10-git-send-email-keescook@chromium.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Thomas Gleixner <tglx@linutronix.de>,
        Wim Van Sebroeck <wim@iguana.be>,
        Guenter Roeck <linux@roeck-us.net>,
        Geert Uytterhoeven <geert@linux-m68k.org>,
        linux-mips@linux-mips.org, linux-watchdog@vger.kernel.org,
        Andrew Morton <akpm@linux-foundation.org>,
        Arnd Bergmann <arnd@arndb.de>,
        Benjamin Herrenschmidt <benh@kernel.crashing.org>,
        Chris Metcalf <cmetcalf@mellanox.com>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        Harish Patil <harish.patil@cavium.com>,
        Heiko Carstens <heiko.carstens@de.ibm.com>,
        "James E.J. Bottomley" <jejb@linux.vnet.ibm.com>,
        John Stultz <john.stultz@linaro.org>,
        Julian Wiedmann <jwi@linux.vnet.ibm.com>,
        Kalle Valo <kvalo@qca.qualcomm.com>,
        Lai Jiangshan <jiangshanlai@gmail.com>,
        Len Brown <len.brown@intel.com>,
        Manis
To: Kees Cook <keescook@chromium.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eddie.linux-mips.org ([148.251.95.138]:47710 "EHLO
        cvs.linux-mips.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754801AbdJINXj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 9 Oct 2017 09:23:39 -0400
Content-Disposition: inline
In-Reply-To: <1507159627-127660-10-git-send-email-keescook@chromium.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 04, 2017 at 04:27:03PM -0700, Kees Cook wrote:

> Subject: [PATCH 09/13] timer: Remove users of expire and data arguments to
>  DEFINE_TIMER
> 
> The expire and data arguments of DEFINE_TIMER are only used in two places
> and are ignored by the code (malta-display.c only uses mod_timer(),
> never add_timer(), so the preset expires value is ignored). Set both
> sets of arguments to zero.
> 
> Cc: Ralf Baechle <ralf@linux-mips.org>
> Cc: Wim Van Sebroeck <wim@iguana.be>
> Cc: Guenter Roeck <linux@roeck-us.net>
> Cc: Geert Uytterhoeven <geert@linux-m68k.org>
> Cc: linux-mips@linux-mips.org
> Cc: linux-watchdog@vger.kernel.org
> Signed-off-by: Kees Cook <keescook@chromium.org>
> ---
>  arch/mips/mti-malta/malta-display.c | 6 +++---
>  drivers/watchdog/alim7101_wdt.c     | 4 ++--
>  2 files changed, 5 insertions(+), 5 deletions(-)

For malta-display:

Acked-by: Ralf Baechle <ralf@linux-mips.org>

  Ralf
