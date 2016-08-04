From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: [PATCH 1/2] ravb: use SET_RUNTIME_PM_OPS macro
Date: Thu, 4 Aug 2016 15:33:18 +0200
Message-ID: <CAMuHMdU-czrkroEKkWg-WFJ7ayqhGntDtuaRXFoyQnm_wDdxvw@mail.gmail.com>
References: <20160803135647.23242-1-niklas.soderlund+renesas@ragnatech.se> <20160803135647.23242-2-niklas.soderlund+renesas@ragnatech.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Linux-Renesas <linux-renesas-soc@vger.kernel.org>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	"David S. Miller" <davem@davemloft.net>,
	Wolfram Sang <wsa@the-dreams.de>
To: =?UTF-8?Q?Niklas_S=C3=B6derlund?=
	<niklas.soderlund+renesas@ragnatech.se>
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
In-Reply-To: <20160803135647.23242-2-niklas.soderlund+renesas@ragnatech.se>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 3, 2016 at 3:56 PM, Niklas Söderlund
<niklas.soderlund+renesas@ragnatech.se> wrote:
> Use macro to define the runtime PM operations.
>
> Signed-off-by: Niklas Söderlund <niklas.soderlund+renesas@ragnatech.se>

Duplicate of  commit 524c6f691b99065577b245b250efe93fb0cda5c4
Author: Kazuya Mizuguchi <kazuya.mizuguchi.ks@renesas.com>
Date:   Mon May 30 05:25:43 2016 +0900

    ravb: Add SET_RUNTIME_PM_OPS macro

    Use SET_RUNTIME_PM_OPS macro instead of assigning a member of
    dev_pm_ops directly.

    Signed-off-by: Kazuya Mizuguchi <kazuya.mizuguchi.ks@renesas.com>
    Signed-off-by: Yoshihiro Kaneko <ykaneko0929@gmail.com>
    Acked-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
