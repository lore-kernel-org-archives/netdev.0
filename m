From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: linux-next: build failure after merge of the net-next tree
Date: Wed, 18 Dec 2013 09:33:47 +0100
Message-ID: <CAMuHMdUi4GQYR2p7enikEkTq1s-5YwirTzmo_tS0JwiE=dVmYw@mail.gmail.com>
References: <20131218125643.8ff140371e1f8c306327d354@canb.auug.org.au>
	<20131217.212145.893665929052097867.davem@davemloft.net>
	<20131217.213033.1019416869378407851.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Stephen Rothwell <sfr@canb.auug.org.au>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Linux-Next <linux-next@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	ffusco@redhat.com, dborkman@redhat.com, tgraf@redhat.com
To: David Miller <davem@davemloft.net>,
	Peter Zijlstra <peterz@infradead.org>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20131217.213033.1019416869378407851.davem@davemloft.net>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Dec 18, 2013 at 3:30 AM, David Miller <davem@davemloft.net> wrote:
> diff --git a/arch/alpha/include/asm/Kbuild b/arch/alpha/include/asm/Kbuild
> index f01fb50..a73a8e2 100644
> --- a/arch/alpha/include/asm/Kbuild
> +++ b/arch/alpha/include/asm/Kbuild
> @@ -4,3 +4,4 @@ generic-y += clkdev.h
>  generic-y += exec.h
>  generic-y += trace_clock.h
>  generic-y += preempt.h
> +generic-y += hash.h

Please keep them sorted.

Yes, Peter violated that too, when adding preempt.h.

Thanks!

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
