From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 2/2] sh_eth: Do not print an error message for probe
 deferral
Date: Thu, 18 May 2017 19:37:40 +0300
Message-ID: <cc02d9b2-8a40-e277-4779-980abdf5117b@cogentembedded.com>
References: <1495112495-25086-1-git-send-email-geert+renesas@glider.be>
 <1495112495-25086-2-git-send-email-geert+renesas@glider.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Laurent Pinchart <laurent.pinchart+renesas@ideasonboard.com>,
        netdev@vger.kernel.org, linux-renesas-soc@vger.kernel.org
To: Geert Uytterhoeven <geert+renesas@glider.be>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
In-Reply-To: <1495112495-25086-2-git-send-email-geert+renesas@glider.be>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 05/18/2017 04:01 PM, Geert Uytterhoeven wrote:

> EPROBE_DEFER is not an error, hence printing an error message like
>
>     sh-eth ee700000.ethernet: failed to initialise MDIO
>
> may confuse the user.
>
> To fix this, suppress the error message in case of probe deferral.
> While at it, shorten the message, and add the actual error code.
>
> Signed-off-by: Geert Uytterhoeven <geert+renesas@glider.be>

Acked-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

MBR, Sergei
