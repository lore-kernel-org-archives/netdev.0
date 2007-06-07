From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] NET: Multiqueue network device support.
Date: Thu, 07 Jun 2007 18:54:08 -0400
Message-ID: <1181256848.4071.57.camel@localhost>
References: <1181219380.4064.55.camel@localhost>
	 <46681E41.6060700@intel.com> <1181253445.4071.4.camel@localhost>
	 <20070607.154421.109060486.davem@davemloft.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: auke-jan.h.kok@intel.com, jeff@garzik.org, kaber@trash.net,
	peter.p.waskiewicz.jr@intel.com, netdev@vger.kernel.org,
	jesse.brandeburg@intel.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ag-out-0708.google.com ([72.14.246.240]:33228 "EHLO
	ag-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965923AbXFGWyM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jun 2007 18:54:12 -0400
Received: by ag-out-0708.google.com with SMTP id 35so535340aga
        for <netdev@vger.kernel.org>; Thu, 07 Jun 2007 15:54:12 -0700 (PDT)
In-Reply-To: <20070607.154421.109060486.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2007-07-06 at 15:44 -0700, David Miller wrote:
> From: jamal <hadi@cyberus.ca>
> Date: Thu, 07 Jun 2007 17:57:25 -0400
> 
> > I empathize but take a closer look; seems mostly useless.
> 
> I thought E1000 still uses LLTX, and if so then multiple cpus can most
> definitely get into the ->hard_start_xmit() in parallel.

AFAICS, only one CPU can dequeue from the qdisc i.e s/he who holds
__LINK_STATE_QDISC_RUNNING is the only one who can call qdisc_restart
and only s/he can enter ->hard_start_xmit().

Am i missing something?

cheers,
jamal

