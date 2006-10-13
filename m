From: Bill Fink <billfink@mindspring.com>
Subject: Re: [PATCH 9/14] [TIPC] Name publication events now delivered in
 chronological order
Date: Fri, 13 Oct 2006 19:13:37 -0400
Message-ID: <20061013191337.cdee991b.billfink@mindspring.com>
References: <Pine.LNX.4.64.0610131330350.30166@ulinpc219.uab.ericsson.se>
	<1160739475953-git-send-email-per.liden@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Allan Stephens <allan.stephens@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-scoter.atl.sa.earthlink.net ([209.86.89.67]:43750 "EHLO
	elasmtp-scoter.atl.sa.earthlink.net") by vger.kernel.org with ESMTP
	id S1751977AbWJMXNo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Oct 2006 19:13:44 -0400
To: Per Liden <per.liden@ericsson.com>
In-Reply-To: <1160739475953-git-send-email-per.liden@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

FYI,

At least here, I received two copies of patch 9/14 and no copy
of patch 10/14.

						-Bill



On Fri, 13 Oct 2006 13:37:50 +0200, Per Liden wrote:

> From: Allan Stephens <allan.stephens@windriver.com>
> 
> This patch tivially re-orders the entries in TIPC's list of local
> publications so that applications will receive publication events
> in the order they were published.
> 
> Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
> Signed-off-by: Per Liden <per.liden@ericsson.com>
> ---
>  net/tipc/name_distr.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/net/tipc/name_distr.c b/net/tipc/name_distr.c
> index f0b063b..03bd659 100644
> --- a/net/tipc/name_distr.c
> +++ b/net/tipc/name_distr.c
> @@ -122,7 +122,7 @@ void tipc_named_publish(struct publicati
>  	struct sk_buff *buf;
>  	struct distr_item *item;
>  
> -	list_add(&publ->local_list, &publ_root);
> +	list_add_tail(&publ->local_list, &publ_root);
>  	publ_cnt++;
>  
>  	buf = named_prepare_buf(PUBLICATION, ITEM_SIZE, 0);
> -- 
> 1.4.1
