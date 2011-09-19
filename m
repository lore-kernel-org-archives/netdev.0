From: Joe Perches <joe@perches.com>
Subject: Re: linux-next: manual merge of the net tree with Linus' tree
Date: Mon, 19 Sep 2011 08:54:41 -0700
Message-ID: <1316447682.6276.5.camel@Joe-Laptop>
References: <20110919145103.6c3e73edf51599eaa703294a@canb.auug.org.au>
	 <1316415318.26848.4.camel@lb-tlvb-dmitry>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Stephen Rothwell <sfr@canb.auug.org.au>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-next@vger.kernel.org" <linux-next@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Yaniv Rosner <yaniv.rosner@broadcom.com>,
	Eilon Greenstein <eilong@broadcom.com>
To: dmitry@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:52064 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756411Ab1ISPym (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Sep 2011 11:54:42 -0400
In-Reply-To: <1316415318.26848.4.camel@lb-tlvb-dmitry>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2011-09-19 at 09:55 +0300, Dmitry Kravkov wrote:
> On Sun, 2011-09-18 at 21:51 -0700, Stephen Rothwell wrote:
> > Today's linux-next merge of the net tree got a conflict in
> > drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c between commit
> > c482e6c06461 ("bnx2x: Fix ETS bandwidth") from Linus' tree and commit
> > 94f05b0f60de ("bnx2x: Coalesce pr_cont uses and fix DP typos") from the
> > net tree.
[]
> Can you use this one instead?
> Contains spell fixes and some formatting.

Hey Dmitry.

The toatl/total spelling fix is good,
but I think this isn't better and is
in fact worse.

> diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
> index 8e9b87b..733ace0 100644
> --- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
> +++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
> @@ -850,32 +850,24 @@ static int bnx2x_ets_e3b0_get_total_bw(
[]
> -			DP(NETIF_MSG_LINK,
> -			   "bnx2x_ets_E3B0_config toatl BW shouldn't be 0\n");
> +			DP(NETIF_MSG_LINK, "bnx2x_ets_E3B0_config total BW"
> +					   "shouldn't be 0\n");

Multiple line format strings lines are bad style and error prone.
You introduce broken spacing after string coalescing.

> -		DP(NETIF_MSG_LINK,
> -		   "bnx2x_ets_E3B0_config toatl BW should be 100\n");
> -		/**
> -		*   We can handle a case whre the BW isn't 100 this can happen
> -		*   if the TC are joined.
> -		*/
> +		DP(NETIF_MSG_LINK, "bnx2x_ets_E3B0_config total BW should be"
> +				   "100\n");

Here too.
