From: Flavio Leitner <fleitner@redhat.com>
Subject: Re: [PATCH net-next] bonding: make
 bond_resend_igmp_join_requests_delayed static
Date: Fri, 15 Oct 2010 18:40:36 -0300
Message-ID: <20101015214036.GA2747@redhat.com>
References: <20101015140256.4192fd34@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Jay Vosburgh <fubar@us.ibm.com>, netdev@vger.kernel.org,
	bonding-devel@lists.sourceforge.net
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:1026 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750779Ab0JOVkr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Oct 2010 17:40:47 -0400
Content-Disposition: inline
In-Reply-To: <20101015140256.4192fd34@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 15, 2010 at 02:02:56PM -0700, Stephen Hemminger wrote:
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> 
> --- a/drivers/net/bonding/bond_main.c	2010-10-15 13:52:01.747192520 -0700
> +++ b/drivers/net/bonding/bond_main.c	2010-10-15 13:52:39.004286643 -0700
> @@ -914,7 +914,7 @@ static void bond_resend_igmp_join_reques
>  	read_unlock(&bond->lock);
>  }
>  
> -void bond_resend_igmp_join_requests_delayed(struct work_struct *work)
> +static void bond_resend_igmp_join_requests_delayed(struct work_struct *work)
>  {
>  	struct bonding *bond = container_of(work, struct bonding,
>  							mcast_work.work);

Indeed, thanks.
Acked-by: Flavio Leitner <fleitner@redhat.com>

-- 
Flavio
