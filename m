From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] e1000e: Fix typo ! &
Date: Tue, 30 Oct 2007 14:33:13 -0400
Message-ID: <472778E9.4050009@garzik.org>
References: <20071029175005.26219.60547.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, 12o3l@tiscali.nl
To: Auke Kok <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:60791 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756546AbXJ3SdO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Oct 2007 14:33:14 -0400
In-Reply-To: <20071029175005.26219.60547.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Auke Kok wrote:
> From: Roel Kluin <12o3l@tiscali.nl>
> 
> Signed-off-by: Roel Kluin <12o3l@tiscali.nl>
> Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
> ---
> 
>  drivers/net/e1000e/82571.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/e1000e/82571.c b/drivers/net/e1000e/82571.c
> index cf70522..14141a5 100644
> --- a/drivers/net/e1000e/82571.c
> +++ b/drivers/net/e1000e/82571.c
> @@ -283,7 +283,7 @@ static s32 e1000_get_invariants_82571(struct e1000_adapter *adapter)
>  			adapter->flags &= ~FLAG_HAS_WOL;
>  		/* quad ports only support WoL on port A */
>  		if (adapter->flags & FLAG_IS_QUAD_PORT &&
> -		    (!adapter->flags & FLAG_IS_QUAD_PORT_A))
> +		    (!(adapter->flags & FLAG_IS_QUAD_PORT_A)))
>  			adapter->flags &= ~FLAG_HAS_WOL;
>  		break;

applied


