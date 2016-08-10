From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: [PATCH] net: ipconfig: fix use after free
Date: Wed, 10 Aug 2016 12:00:35 +0200
Message-ID: <CAMuHMdV=MsCUzuGJ76jWaw7kmMm7o1c3Dvpn50rCaJ2a7wS2iw@mail.gmail.com>
References: <CAMuHMdVjugL0y-C+vet=qbcER8rjuFKwFgrutRUAs=uOk0JZ1A@mail.gmail.com>
 <1470822257-13275-1-git-send-email-u.kleine-koenig@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8BIT
Cc: "David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Linux-Renesas <linux-renesas-soc@vger.kernel.org>,
	Sascha Hauer <kernel@pengutronix.de>
To: =?UTF-8?Q?Uwe_Kleine=2DK=C3=B6nig?=
	<u.kleine-koenig@pengutronix.de>
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
In-Reply-To: <1470822257-13275-1-git-send-email-u.kleine-koenig@pengutronix.de>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Uwe,

On Wed, Aug 10, 2016 at 11:44 AM, Uwe Kleine-König
<u.kleine-koenig@pengutronix.de> wrote:
> ic_close_devs() calls kfree() for all devices's ic_device. Since commit
> 2647cffb2bc6 ("net: ipconfig: Support using "delayed" DHCP replies")
> the active device's ic_device is still used however to print the
> ipconfig summary which results in an oops if the memory is already
> changed. So delay freeing until after the autoconfig results are
> reported.

Thanks!

> Fixes: 2647cffb2bc6 ("net: ipconfig: Support using "delayed" DHCP replies")
> Reported-by: Geert Uytterhoeven <geert@linux-m68k.org>
> Signed-off-by: Uwe Kleine-König <u.kleine-koenig@pengutronix.de>

Tested-by: Geert Uytterhoeven <geert+renesas@glider.be>

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
