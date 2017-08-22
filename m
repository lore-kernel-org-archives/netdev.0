From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: [PATCH] ravb: make mdiobb_ops const
Date: Tue, 22 Aug 2017 14:06:58 +0200
Message-ID: <CAMuHMdU3wCY8ffvVykMv21Wjy4Oc=PPFN8-=raa9-rTcnDPYmw@mail.gmail.com>
References: <1503389282-17369-1-git-send-email-bhumirks@gmail.com> <1f074a7c-0d3a-e569-4400-c50d967e550c@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Bhumika Goyal <bhumirks@gmail.com>,
        Julia Lawall <julia.lawall@lip6.fr>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Linux-Renesas <linux-renesas-soc@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1f074a7c-0d3a-e569-4400-c50d967e550c@cogentembedded.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 22, 2017 at 2:03 PM, Sergei Shtylyov
<sergei.shtylyov@cogentembedded.com> wrote:
> On 08/22/2017 11:08 AM, Bhumika Goyal wrote:
>> Make these const as they are only stored in a const field of a
>> mdiobb_ctrl structure.
>
>> Signed-off-by: Bhumika Goyal <bhumirks@gmail.com>
>> ---
>>   drivers/net/ethernet/renesas/ravb_main.c | 2 +-
>>   drivers/net/ethernet/renesas/sh_eth.c    | 2 +-
>>   2 files changed, 2 insertions(+), 2 deletions(-)
>
>    If you're fixing both Renesas drivers at once, your subject should be
> "renesas: make mdiobb_ops const". With that fixed, you have my:

"net: renesas: make mdiobb_ops const"?
There are plenty of other Renesas-specific drivers spread all over the tree.

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
