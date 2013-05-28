From: Fabio Estevam <festevam@gmail.com>
Subject: Re: [PATCH] net: ethernet: freescale: use devm_ioremap_resource()
Date: Tue, 28 May 2013 15:32:33 -0300
Message-ID: <CAOMZO5BM+tG3S8Bj88CMwMLDf2uD-CW3TTjM5Dw4N-h4rt5frA@mail.gmail.com>
References: <1368473874-9569-1-git-send-email-laurent.navet@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: davem@davemloft.net, Frank.Li@freescale.com,
	fabio.estevam@freescale.com, shawn.guo@linaro.org, joe@perches.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Laurent Navet <laurent.navet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1368473874-9569-1-git-send-email-laurent.navet@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Laurent,

On Mon, May 13, 2013 at 4:37 PM, Laurent Navet <laurent.navet@gmail.com> wrote:
> Replace a call to deprecated devm_request_and_ioremap by devm_ioremap_resource.
> also remove tests on 'r' since devm_ioremap_resource() checks for it
> in a better way.
>
> Found with coccicheck and this semantic patch:
>  scripts/coccinelle/api/devm_ioremap_resource.cocci
>
> Signed-off-by: Laurent Navet <laurent.navet@gmail.com>

I was about to do the same change, then I saw your patch :-)

Looks good:

Tested-by: Fabio Estevam <fabio.estevam@freescale.com>
