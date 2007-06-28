From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 3/3] NET: [SCHED] Qdisc changes and sch_rr added for multiqueue
Date: Thu, 28 Jun 2007 18:35:47 +0200
Message-ID: <4683E363.6020607@trash.net>
References: <20070628162056.18728.20195.stgit@localhost.localdomain> <20070628162118.18728.64391.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, jeff@garzik.org,
	auke-jan.h.kok@intel.com, hadi@cyberus.ca
To: PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:54605 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756936AbXF1QhT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jun 2007 12:37:19 -0400
In-Reply-To: <20070628162118.18728.64391.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

PJ Waskiewicz wrote:

> +
>  static int __init prio_module_init(void)
>  {
> -	return register_qdisc(&prio_qdisc_ops);
> +	int err;
> +	err = register_qdisc(&prio_qdisc_ops);
> +	if (!err)
> +		err = register_qdisc(&rr_qdisc_ops);
> +	return err;
>  }
>  

Thats still broken. I'll fix this and some minor cleanness issues myself so
you don't have to go through another resend.

