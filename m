From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: Build regressions/improvements in v4.14-rc2
Date: Wed, 27 Sep 2017 09:28:35 +0200
Message-ID: <CAMuHMdWFtjSV1S_+AQuRRpgjPykdQ7iSG=iL0UZUpW3WxA8b8g@mail.gmail.com>
References: <1506497166-20647-1-git-send-email-geert@linux-m68k.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: sparclinux <sparclinux@vger.kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Return-path: <sparclinux-owner@vger.kernel.org>
In-Reply-To: <1506497166-20647-1-git-send-email-geert@linux-m68k.org>
Sender: sparclinux-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 27, 2017 at 9:26 AM, Geert Uytterhoeven
<geert@linux-m68k.org> wrote:
> JFYI, when comparing v4.14-rc2[1] to v4.14-rc1[3], the summaries are:
>   - build errors: +1/-2

  + /home/kisskb/slave/src/drivers/net/ethernet/intel/i40e/i40e_ethtool.c:
error: implicit declaration of function 'cmpxchg64'
[-Werror=implicit-function-declaration]:  => 4150:6

sparc64/sparc-allmodconfig

> [1] http://kisskb.ellerman.id.au/kisskb/head/e19b205be43d11bff638cad4487008c48d21c103/ (all 267 configs)
> [3] http://kisskb.ellerman.id.au/kisskb/head/2bd6bf03f4c1c59381d62c61d03f6cc3fe71f66e/ (all 267 configs)

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
