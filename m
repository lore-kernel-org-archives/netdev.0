From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH/RFC] ravb: Support 1Gbps on R-Car H3 ES1.1+ and R-Car M3-W
Date: Wed, 9 Nov 2016 22:02:58 +0300
Message-ID: <6c28b185-2283-fbbe-7850-4bc66c8581b0@cogentembedded.com>
References: <1477934018-13968-1-git-send-email-geert+renesas@glider.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Simon Horman <horms+renesas@verge.net.au>,
        Arnd Bergmann <arnd@arndb.de>, netdev@vger.kernel.org,
        linux-renesas-soc@vger.kernel.org
To: Geert Uytterhoeven <geert+renesas@glider.be>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
In-Reply-To: <1477934018-13968-1-git-send-email-geert+renesas@glider.be>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 10/31/2016 08:13 PM, Geert Uytterhoeven wrote:

> The limitation to 10/100Mbit speeds on R-Car Gen3 is valid for R-Car H3
> ES1.0 only. Check for the exact SoC model to allow 1Gbps on newer
> revisions of R-Car H3, and on R-Car M3-W.
>
> Signed-off-by: Geert Uytterhoeven <geert+renesas@glider.be>
> ---
> Tested on:
>   - r8a7795/salvator-x with R-Car H3 ES1.0 (limited to 100Mbps),
>   - r8a7795/salvator-x with R-Car H3 ES1.1 (1Gbps),
>   - r8a7796/salvator-x with R-Car M3-W ES1.0 (1Gbps).
>
> This is marked as an RFC because it depends on:
>   A) the soc_device_match() infrastructure,
>   B) Renesas SoC core ESx.y handling.
> Hence I think the best merge strategy is to let this patch go in through
> Simon's Renesas tree.

    I'm not seeing soc_device_match() and friends even in renesas.git repo...
What else do I need to review this patch?

MBR, Sergei
