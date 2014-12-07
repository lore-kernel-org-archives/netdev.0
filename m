From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net-next v3 2/2] rocker: remove swdev mode
Date: Sun, 7 Dec 2014 08:19:28 +0000
Message-ID: <20141207081928.GA2215@casper.infradead.org>
References: <1417935267-6000-3-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jiri@resnulli.us, sfeldma@gmail.com, jhs@mojatatu.com,
	bcrl@kvack.org, john.fastabend@gmail.com,
	stephen@networkplumber.org, linville@tuxdriver.com,
	vyasevic@redhat.com, netdev@vger.kernel.org, davem@davemloft.net,
	shm@cumulusnetworks.com, gospo@cumulusnetworks.com
To: roopa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:43051 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752411AbaLGITe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Dec 2014 03:19:34 -0500
Content-Disposition: inline
In-Reply-To: <1417935267-6000-3-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/06/14 at 10:54pm, roopa@cumulusnetworks.com wrote:
> From: Roopa Prabhu <roopa@cumulusnetworks.com>
> 
> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
> ---
>  drivers/net/ethernet/rocker/rocker.c |   18 +-----------------
>  include/linux/rtnetlink.h            |    2 +-
>  net/core/rtnetlink.c                 |   12 +++++++++---
>  3 files changed, 11 insertions(+), 21 deletions(-)
> 
> diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
> index fded127..9f1d256 100644
> --- a/drivers/net/ethernet/rocker/rocker.c
> +++ b/drivers/net/ethernet/rocker/rocker.c
> @@ -3755,7 +3739,7 @@ static int rocker_port_bridge_getlink(struct sk_buff *skb, u32 pid, u32 seq,
>  				      u32 filter_mask)
>  {
>  	struct rocker_port *rocker_port = netdev_priv(dev);
> -	u16 mode = BRIDGE_MODE_SWDEV;
> +	u16 mode = -1;
        ^^^

I assume you meant s16
