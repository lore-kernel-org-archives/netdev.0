From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: [PATCH 4/5] dev: Add dev_vprintk_emit and dev_printk_emit
Date: Tue, 25 Sep 2012 23:05:03 +0200
Message-ID: <CAMuHMdVH-ni1NhbTDXgh82WUSAV85fahUjp1BoizVy6D2Xyvaw@mail.gmail.com>
References: <cover.1345978012.git.joe@perches.com>
	<7cfb202968f0928bba66965146a828a1cff87950.1345978012.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	"David S. Miller" <davem@davemloft.net>,
	Jason Baron <jbaron@redhat.com>,
	Jim Cromie <jim.cromie@gmail.com>, Kay Sievers <kay@vrfy.org>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <7cfb202968f0928bba66965146a828a1cff87950.1345978012.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Aug 26, 2012 at 1:25 PM, Joe Perches <joe@perches.com> wrote:
> --- a/include/linux/device.h
> +++ b/include/linux/device.h
> @@ -914,6 +918,13 @@ int _dev_info(const struct device *dev, const char *fmt, ...);
>
>  #else
>
> +static int dev_vprintk_emit(int level, const struct device *dev,

Missing "inline", cfr. http://kisskb.ellerman.id.au/kisskb/buildresult/7271354/

include/linux/device.h:930:12: error: 'dev_vprintk_emit' defined but
not used [-Werror=unused-function]
cc1: all warnings being treated as errors
make[2]: *** [arch/sh/kernel/dma-nommu.o] Error 1

> +                           const char *fmt, va_list args)
> +{ return 0; }

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
