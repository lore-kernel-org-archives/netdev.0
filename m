From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: [PATCH 03/15] ethernet: amd: use IS_ENABLED() instead of checking
 for built-in or module
Date: Mon, 12 Sep 2016 16:11:02 +0200
Message-ID: <CAMuHMdWgH+F1CjhtAgkeMt_mG6RJW8kEEbPdBoopBD+y70-1uA@mail.gmail.com>
References: <1473689026-6983-1-git-send-email-javier@osg.samsung.com> <1473689026-6983-4-git-send-email-javier@osg.samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        Florian Westphal <fw@strlen.de>,
        Antonio Quartulli <a@unstable.cc>,
        Mugunthan V N <mugunthanvnm@ti.com>
To: Javier Martinez Canillas <javier@osg.samsung.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1473689026-6983-4-git-send-email-javier@osg.samsung.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Sep 12, 2016 at 4:03 PM, Javier Martinez Canillas
<javier@osg.samsung.com> wrote:
> The IS_ENABLED() macro checks if a Kconfig symbol has been enabled either
> built-in or as a module, use that macro instead of open coding the same.
>
> Using the macro makes the code more readable by helping abstract away some
> of the Kconfig built-in and module enable details.
>
> Signed-off-by: Javier Martinez Canillas <javier@osg.samsung.com>

Reviewed-by: Geert Uytterhoeven <geert@linux-m68k.org>

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
