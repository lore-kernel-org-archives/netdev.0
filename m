From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 1/2] sh_eth: Use platform device for printing before
 register_netdev()
Date: Thu, 18 May 2017 19:32:01 +0300
Message-ID: <bc664329-3010-32d2-fa39-2557dbf6da8c@cogentembedded.com>
References: <1495112495-25086-1-git-send-email-geert+renesas@glider.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Laurent Pinchart <laurent.pinchart+renesas@ideasonboard.com>,
        netdev@vger.kernel.org, linux-renesas-soc@vger.kernel.org
To: Geert Uytterhoeven <geert+renesas@glider.be>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
In-Reply-To: <1495112495-25086-1-git-send-email-geert+renesas@glider.be>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 05/18/2017 04:01 PM, Geert Uytterhoeven wrote:

> The MDIO initialization failure message is printed using the network
> device, before it has been registered, leading to:
>
>      (null): failed to initialise MDIO
>
> Use the platform device instead to fix this:
>
>     sh-eth ee700000.ethernet: failed to initialise MDIO
>
> Fixes: daacf03f0bbfefee ("sh_eth: Register MDIO bus before registering the network device")
> Signed-off-by: Geert Uytterhoeven <geert+renesas@glider.be>

Acked-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

MBR, Sergei
