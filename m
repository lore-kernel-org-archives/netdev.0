From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: ravb WoL interrupt flood
Date: Tue, 30 May 2017 11:23:23 +0200
Message-ID: <CAMuHMdWmt7oB4B4OYkO59+HvEbpVLVeqB_AV2c5OnYJEUJRxRg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
        Linux-Renesas <linux-renesas-soc@vger.kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: =?UTF-8?Q?Niklas_S=C3=B6derlund?= <niklas.soderlund@ragnatech.se>
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Niklas,

I just got a flood of messages after WoL from s2idle on r8a7795/salvator-x:

[  802.341060] ravb e6800000.ethernet eth0: ignoring interrupt, rx
status 0x00000001, rx mask 0x00000001,
[  802.350369] ravb e6800000.ethernet eth0:                     tx
status 0x00000000, tx mask 0x00000001.
[  802.359684] ravb e6800000.ethernet eth0: ignoring interrupt, rx
status 0x00000001, rx mask 0x00000001,
[  802.368993] ravb e6800000.ethernet eth0:                     tx
status 0x00000000, tx mask 0x00000001.
[  802.378308] ravb e6800000.ethernet eth0: ignoring interrupt, rx
status 0x00000001, rx mask 0x00000001,
[  802.387616] ravb e6800000.ethernet eth0:                     tx
status 0x00000000, tx mask 0x00000001.
[  802.396931] ravb e6800000.ethernet eth0: ignoring interrupt, rx
status 0x00000001, rx mask 0x00000001,
[  802.406240] ravb e6800000.ethernet eth0:                     tx
status 0x00000000, tx mask 0x00000001.
...

Unfortunately I cannot reproduce it.

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
