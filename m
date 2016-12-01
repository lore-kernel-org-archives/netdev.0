From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] sh_eth: add missing checks for status bits
Date: Thu, 1 Dec 2016 13:24:18 +0300
Message-ID: <aad0720f-2515-f1a0-d3ee-310562267594@cogentembedded.com>
References: <20161130200148.9011-1-chris.brandt@renesas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Simon Horman <horms+renesas@verge.net.au>,
        Geert Uytterhoeven <geert+renesas@glider.be>,
        netdev@vger.kernel.org, linux-renesas-soc@vger.kernel.org
To: Chris Brandt <chris.brandt@renesas.com>,
        David Miller <davem@davemloft.net>
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
In-Reply-To: <20161130200148.9011-1-chris.brandt@renesas.com>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello!

    Please always CC me on the sh_eth/ravb driver patches as directed by 
scripts/get_maintainer.pl.

On 11/30/2016 11:01 PM, Chris Brandt wrote:

> When streaming a lot of data and the RZ can't keep up, some status bits
> will get set that are not being checked or cleared which cause the
> following messages and the Ethernet driver to stop working. This
> patch fixes that issue.

    Perhaps we should just clear the correspoding bits in EESIPR instead? They 
are not set for any other SoC...

> irq 21: nobody cared (try booting with the "irqpoll" option)
> handlers:
> [<c036b71c>] sh_eth_interrupt
> Disabling IRQ #21
>
> Fixes: db893473d313a4ad ("sh_eth: Add support for r7s72100")
> Signed-off-by: Chris Brandt <chris.brandt@renesas.com>

MBR, Sergei
