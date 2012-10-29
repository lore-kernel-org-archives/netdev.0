From: Alexandre Pereira da Silva <aletes.xgr@gmail.com>
Subject: Re: [PATCH 1/2] drivers/net/ethernet/nxp/lpc_eth.c: Call
 mdiobus_unregister before mdiobus_free
Date: Mon, 29 Oct 2012 09:58:11 -0200
Message-ID: <CAAAP30Gm56x+k92iCxG20a8ONsWgKqyYfsZXBQMuU9j9zx6b1Q@mail.gmail.com>
References: <1351440721-9121-1-git-send-email-peter.senna@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: davem@davemloft.net, stigge@antcom.de, edumazet@google.com,
	djduanjiong@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Peter Senna Tschudin <peter.senna@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1351440721-9121-1-git-send-email-peter.senna@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Oct 28, 2012 at 2:12 PM, Peter Senna Tschudin
<peter.senna@gmail.com> wrote:
> Based on commit b27393aecf66199f5ddad37c302d3e0cfadbe6c0
>
> Calling mdiobus_free without calling mdiobus_unregister causes
> BUG_ON(). This patch fixes the issue.
>
> The semantic patch that found this issue(http://coccinelle.lip6.fr/):
> // <smpl>
> @@
> expression E;
> @@
>   ... when != mdiobus_unregister(E);
>
> + mdiobus_unregister(E);
>   mdiobus_free(E);
> // </smpl>
>
> Signed-off-by: Peter Senna Tschudin <peter.senna@gmail.com>
> ---

Tested-by: Alexandre Pereira da Silva <aletes.xgr@gmail.com>
