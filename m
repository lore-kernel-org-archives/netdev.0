From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 1/7] e1000e: Return 1 instead of a non-zero value for
 link up	indication
Date: Thu, 14 Aug 2008 04:46:40 -0400
Message-ID: <48A3F0F0.1060000@garzik.org>
References: <20080809013544.23913.47157.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	akpm@linux-foundation.org, Bruce Allan <bruce.w.allan@intel.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:36310 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757959AbYHNIqn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Aug 2008 04:46:43 -0400
In-Reply-To: <20080809013544.23913.47157.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jeff Kirsher wrote:
> From: Bruce Allan <bruce.w.allan@intel.com>
> 
> A number of users have mentioned they have tools that rely on a link-up
> indication having a return value of 1 rather than a non-zero value.
> 
> Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
> 
>  drivers/net/e1000e/ethtool.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/e1000e/ethtool.c b/drivers/net/e1000e/ethtool.c
> index cf9679f..e21c9e0 100644
> --- a/drivers/net/e1000e/ethtool.c
> +++ b/drivers/net/e1000e/ethtool.c
> @@ -177,7 +177,7 @@ static u32 e1000_get_link(struct net_device *netdev)
>  	u32 status;
>  	
>  	status = er32(STATUS);
> -	return (status & E1000_STATUS_LU);
> +	return (status & E1000_STATUS_LU) ? 1 : 0;

applied 1-7


