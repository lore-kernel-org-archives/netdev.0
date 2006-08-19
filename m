From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH 5/7] ip1000: Modify coding style of ipg_config_autoneg()
Date: Sat, 19 Aug 2006 12:17:17 +0200
Message-ID: <20060819101717.GA26267@electric-eye.fr.zoreil.com>
References: <1155844061.5006.13.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: penberg@cs.Helsinki.FI, akpm@osdl.org, dvrabel@cantab.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	david@pleyades.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:10210 "EHLO
	fr.zoreil.com") by vger.kernel.org with ESMTP id S1751697AbWHSKTX
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 19 Aug 2006 06:19:23 -0400
To: Jesse Huang <jesse@icplus.com.tw>
Content-Disposition: inline
In-Reply-To: <1155844061.5006.13.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jesse Huang <jesse@icplus.com.tw> :
> From: Jesse Huang <jesse@icplus.com.tw>
> 
> This is only coding style modify for ipg_config_autoneg(). Thanks for the
> suggestion form Francois.
> 
> Change Logs:
>     Modify coding style of ipg_config_autoneg()
> 
> ---
> 
>  drivers/net/ipg.c |   17 ++++++++++-------
>  1 files changed, 10 insertions(+), 7 deletions(-)
> 
> 737498ca620437d8179e21be4d5220333066cbbd
> diff --git a/drivers/net/ipg.c b/drivers/net/ipg.c
> index f859107..be96f93 100644
> --- a/drivers/net/ipg.c
> +++ b/drivers/net/ipg.c
> @@ -491,11 +491,13 @@ static int ipg_config_autoneg(struct net
>  	int fullduplex;
>  	int txflowcontrol;
>  	int rxflowcontrol;
> +	long MacCtrlValue;

Mixed case variables are not exactly welcome.

-- 
Ueimor
