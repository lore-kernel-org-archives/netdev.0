From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH] ravb: Consolidate clock handling
Date: Thu, 12 Oct 2017 11:55:21 +0200
Message-ID: <20171012095508.vjpqvq37474qp2cb@verge.net.au>
References: <1507796693-14268-1-git-send-email-geert+renesas@glider.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S . Miller" <davem@davemloft.net>,
        Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
        Niklas =?utf-8?Q?S=C3=B6derlund?=
        <niklas.soderlund+renesas@ragnatech.se>, netdev@vger.kernel.org,
        linux-renesas-soc@vger.kernel.org
To: Geert Uytterhoeven <geert+renesas@glider.be>
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1507796693-14268-1-git-send-email-geert+renesas@glider.be>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Oct 12, 2017 at 10:24:53AM +0200, Geert Uytterhoeven wrote:
> The module clock is used for two purposes:
>   - Wake-on-LAN (WoL), which is optional,
>   - gPTP Timer Increment (GTI) configuration, which is mandatory.
> 
> As the clock is needed for GTI configuration anyway, WoL is always
> available.  Hence remove duplication and repeated obtaining of the clock
> by making GTI use the stored clock for WoL use.

Hi Geert,

I understand from the statements above that the clock must be present,
but I'm most sure that I understand why that means that WoL is always
available.

Assuming your assertion that WoL is correct the code changes look good to me.
