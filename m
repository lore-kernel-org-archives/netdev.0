From: Manuel Lauss <manuel.lauss@gmail.com>
Subject: Re: [PATCH] MIPS: Remove all the uses of custom gpio.h
Date: Fri, 31 Jul 2015 08:04:09 +0200
Message-ID: <CAOLZvyFdY9z9tVd6BR4H4xnito=X5m_=71bmUr=7FHRGcB-SEw@mail.gmail.com>
References: <1438277338-7246-1-git-send-email-albeu@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux-MIPS <linux-mips@linux-mips.org>,
	Ralf Baechle <ralf@linux-mips.org>,
	Hauke Mehrtens <hauke@hauke-m.de>,
	=?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>,
	Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>,
	Tejun Heo <tj@kernel.org>,
	Linus Walleij <linus.walleij@linaro.org>,
	Alexandre Courbot <gnurou@gmail.com>,
	Dmitry Torokhov <dmitry.torokhov@gmail.com>,
	Florian Fainelli <florian@openwrt.org>,
	Joe Perches <joe@perches.com>,
	Daniel Walter <dwalter@google.com>,
	Sergey Ryazanov <ryazanov.s.a@gmail.com>,
	Huacai Chen <chenhc@lemote.com>,
	Andrew Bresticker <abrestic@chromium.org>,
	James Hartley <james.hartley@imgtec.com>,
	Paul Burton <paul.burton@imgtec.com>,
	Bjorn Helgaas <bhelgaas@google.com>,
	Wolfram Sang <wsa@the-dreams.de>,
	Simon Horman <horms+renesas@verge.net.au>,
	Geert Uytterhoeven <geert@linux-m68k.org>,
	Varka Bhadram <varkabhadram@gmail.com>,
	Ma
To: Alban Bedel <albeu@free.fr>
Return-path: <linux-input-owner@vger.kernel.org>
In-Reply-To: <1438277338-7246-1-git-send-email-albeu@free.fr>
Sender: linux-input-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jul 30, 2015 at 7:28 PM, Alban Bedel <albeu@free.fr> wrote:
> Currently CONFIG_ARCH_HAVE_CUSTOM_GPIO_H is defined for all MIPS
> machines, and each machine type provides its own gpio.h. However
> only a handful really implement the GPIO API, most just forward
> everythings to gpiolib.
>
> The Alchemy machine is notable as it provides a system to allow
> implementing the GPIO API at the board level. But it is not used by
> any board currently supported, so it can also be removed.

Threre's only out-of-tree users which I also maintain, so it's fine with me.


>  arch/mips/alchemy/Kconfig                       |   7 --
>  arch/mips/alchemy/board-gpr.c                   |   1 +
>  arch/mips/alchemy/board-mtx1.c                  |   1 +
>  arch/mips/alchemy/common/Makefile               |   7 +-
>  arch/mips/alchemy/devboards/db1000.c            |   1 +
>  arch/mips/alchemy/devboards/db1300.c            |   1 +
>  arch/mips/alchemy/devboards/db1550.c            |   1 +
>  arch/mips/alchemy/devboards/pm.c                |   2 +-
>  arch/mips/include/asm/mach-au1x00/gpio-au1000.h | 148 ++----------------------
>  arch/mips/include/asm/mach-au1x00/gpio.h        |  86 --------------

For the alchemy parts:

Acked-by: Manuel Lauss <manuel.lauss@gmail.com>


-- 
   Manuel
