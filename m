From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: Build regressions/improvements in v3.19-rc4
Date: Mon, 12 Jan 2015 10:09:32 +0100
Message-ID: <CAMuHMdVZYjkP+R+zY4Q+r-a=4XFnqJTqjHC00LEhZiG34YYZOg@mail.gmail.com>
References: <1421052212-13287-1-git-send-email-geert@linux-m68k.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1421052212-13287-1-git-send-email-geert@linux-m68k.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jan 12, 2015 at 9:43 AM, Geert Uytterhoeven
<geert@linux-m68k.org> wrote:
> JFYI, when comparing v3.19-rc4[1] to v3.19-rc3[3], the summaries are:
>   - build errors: +6/-67

Nothing serious, but

  + error: br_input.c: undefined reference to `arp_send':  => .text+0x82e77)
  + error: br_input.c: undefined reference to `arp_tbl':  => .text+0x82d8b)

i386-randconfig

> [1] http://kisskb.ellerman.id.au/kisskb/head/8294/ (255 out of 262 configs)
> [3] http://kisskb.ellerman.id.au/kisskb/head/8277/ (255 out of 262 configs)

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
