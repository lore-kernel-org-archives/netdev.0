From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: [PATCH/RFC] ravb: Support 1Gbps on R-Car H3 ES1.1+ and R-Car M3-W
Date: Wed, 9 Nov 2016 20:12:48 +0100
Message-ID: <CAMuHMdVJe_N68mA44PnQndxNsPH9L2MyqRVoKdoctfhK1fHRaA@mail.gmail.com>
References: <1477934018-13968-1-git-send-email-geert+renesas@glider.be> <6c28b185-2283-fbbe-7850-4bc66c8581b0@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Geert Uytterhoeven <geert+renesas@glider.be>,
        "David S. Miller" <davem@davemloft.net>,
        Simon Horman <horms+renesas@verge.net.au>,
        Arnd Bergmann <arnd@arndb.de>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Linux-Renesas <linux-renesas-soc@vger.kernel.org>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
In-Reply-To: <6c28b185-2283-fbbe-7850-4bc66c8581b0@cogentembedded.com>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Sergei,

On Wed, Nov 9, 2016 at 8:02 PM, Sergei Shtylyov
<sergei.shtylyov@cogentembedded.com> wrote:
> On 10/31/2016 08:13 PM, Geert Uytterhoeven wrote:
>
>> The limitation to 10/100Mbit speeds on R-Car Gen3 is valid for R-Car H3
>> ES1.0 only. Check for the exact SoC model to allow 1Gbps on newer
>> revisions of R-Car H3, and on R-Car M3-W.
>>
>> Signed-off-by: Geert Uytterhoeven <geert+renesas@glider.be>
>> ---
>> Tested on:
>>   - r8a7795/salvator-x with R-Car H3 ES1.0 (limited to 100Mbps),
>>   - r8a7795/salvator-x with R-Car H3 ES1.1 (1Gbps),
>>   - r8a7796/salvator-x with R-Car M3-W ES1.0 (1Gbps).
>>
>> This is marked as an RFC because it depends on:
>>   A) the soc_device_match() infrastructure,
>>   B) Renesas SoC core ESx.y handling.
>> Hence I think the best merge strategy is to let this patch go in through
>> Simon's Renesas tree.
>
>    I'm not seeing soc_device_match() and friends even in renesas.git repo...
> What else do I need to review this patch?

[PATCH v2 0/7] soc: renesas: Identify SoC and register with the SoC bus

The dependencies are included in renesas-drivers-2016-11-08-v4.9-rc4
(more specifically branch topic/renesas-soc-id-v2).

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
