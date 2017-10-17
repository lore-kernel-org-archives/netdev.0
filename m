From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: [PATCH net-next 3/3] net: sh_eth: implement R-Car Gen[12]
 fallback compatibility strings
Date: Tue, 17 Oct 2017 10:21:21 +0200
Message-ID: <CAMuHMdXPOAKvoo+gGM6T00z5BC04ZzLoR4-0sJJuaxbM4gQLQg@mail.gmail.com>
References: <20171017074747.24159-1-horms+renesas@verge.net.au> <20171017074747.24159-4-horms+renesas@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: David Miller <davem@davemloft.net>,
        Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
        Magnus Damm <magnus.damm@gmail.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Linux-Renesas <linux-renesas-soc@vger.kernel.org>
To: Simon Horman <horms+renesas@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:51118 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934291AbdJQIVX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Oct 2017 04:21:23 -0400
In-Reply-To: <20171017074747.24159-4-horms+renesas@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 17, 2017 at 9:47 AM, Simon Horman
<horms+renesas@verge.net.au> wrote:
> Implement fallback compatibility strings for R-Car Gen 1 and 2.
>
> In the case of Renesas R-Car hardware we know that there are generations of
> SoCs, f.e. Gen 1 and 2. But beyond that its not clear what the relationship
> between IP blocks might be. For example, I believe that r8a7790 is older
> than r8a7791 but that doesn't imply that the latter is a descendant of the
> former or vice versa.
>
> We can, however, by examining the documentation and behaviour of the
> hardware at run-time observe that the current driver implementation appears
> to be compatible with the IP blocks on SoCs within a given generation.
>
> For the above reasons and convenience when enabling new SoCs a
> per-generation fallback compatibility string scheme being adopted for

is being adopted?

> drivers for Renesas SoCs.
>
> Note that R-Car Gen2 and RZ/G1 have many compatible IP blocks.  The
> approach that has been consistently taken for other IP blocks is to name
> common code, compatibility strings and so on after Rcar Gen2.
>
> Signed-off-by: Simon Horman <horms+renesas@verge.net.au>

Reviewed-by: Geert Uytterhoeven <geert+renesas@glider.be>

Gr{oetje,eeting}s,

                        Geert
