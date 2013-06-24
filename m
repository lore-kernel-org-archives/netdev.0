From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: SLIP: Is there a maintainer for drivers/net/slip/slip.c ?
Date: Mon, 24 Jun 2013 10:49:54 +0200
Message-ID: <CAMuHMdXDrPxw2Fs7ncATz+8JTJYu=dm3m0bQrca4KY9UZvyV8A@mail.gmail.com>
References: <51C802DA.4080202@mentor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Dean Jenkins <Dean_Jenkins@mentor.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <51C802DA.4080202@mentor.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jun 24, 2013 at 10:27 AM, Dean Jenkins <Dean_Jenkins@mentor.com> wrote:
> Using the Linux v3.9 tag, I note that
>
> ./scripts/get_maintainer.pl -f drivers/net/slip/slip.c
> netdev@vger.kernel.org (open list:NETWORKING DRIVERS)
> linux-kernel@vger.kernel.org (open list)
>
> There seems to be no maintainer for drivers/net/slip/slip.c, is that true ?

netdev seems to be the most appropriate mailing list, cfr. what
get_maintainer.pl reported, hence CC netdev added.

> I am asking because sl_encaps() and slip_write_wakeup() do not handle error
> codes from tty->ops->write() and a recursive stack overflow crash can occur
> if the tty->ops->write() fails to write all the characters. I have some
> patches to fix this but would like some feedback on an appropriate solution.

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
