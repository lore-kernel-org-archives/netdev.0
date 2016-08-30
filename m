From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: [PATCH] net: ethernet: renesas: sh_eth: do not access POST
 registers if not exist
Date: Tue, 30 Aug 2016 16:26:30 +0200
Message-ID: <CAMuHMdXhSUbP+81K_1vRxvkqecQM2Pn0z5dPOmBQAfqBykdxGg@mail.gmail.com>
References: <20160826200107.20681-1-chris.brandt@renesas.com>
 <87690577-4526-ce66-6ce3-68ac8b20e737@cogentembedded.com> <SG2PR06MB11653F9E20F38972CA11EF328AE10@SG2PR06MB1165.apcprd06.prod.outlook.com>
 <f456cca3-289c-67dc-f15c-5b475553cdde@cogentembedded.com> <SG2PR06MB1165DAEF1E16FFA7E2DC49308AE00@SG2PR06MB1165.apcprd06.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
        "David S . Miller" <davem@davemloft.net>,
        Simon Horman <horms+renesas@verge.net.au>,
        Geert Uytterhoeven <geert+renesas@glider.be>,
        Daniel Palmer <daniel@0x0f.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-renesas-soc@vger.kernel.org"
        <linux-renesas-soc@vger.kernel.org>
To: Chris Brandt <Chris.Brandt@renesas.com>
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
In-Reply-To: <SG2PR06MB1165DAEF1E16FFA7E2DC49308AE00@SG2PR06MB1165.apcprd06.prod.outlook.com>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Chris,

On Tue, Aug 30, 2016 at 4:16 PM, Chris Brandt <Chris.Brandt@renesas.com> wr=
ote:
> On Aug 29, 2016, Sergei Shtylyov wrote:
>>    SH7757 is not the only platform with TSU, there's e.g. R8A7740 ARM
>> SoC which only has 1 GETHER channel...
>
> I don't have the R8A7740 manual (R-Mobile A1) so I can't see. But even if=
 it does not have the POST registers, it might not hurt anything.

R8a7740 does have the POST registers.

> I just looked at the RZ/A1 register space and there seems to be dummy reg=
isters in the POST1-4 area. I can write to them and read back what I wrote.=
..which is all that the sh_eth driver cares about. I bet when the designers=
 bring in the EtherC IP block, the entire register address is always popula=
ted with a simple latch registers. And then, if a feature is not included (=
like relay/POST), then nothing is hooked up on the back side of it.

What a waste of transistors...
There are plenty of hidden registers in many IP blocks.

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k=
.org

In personal conversations with technical people, I call myself a hacker. Bu=
t
when I'm talking to journalists I just say "programmer" or something like t=
hat.
                                -- Linus Torvalds
