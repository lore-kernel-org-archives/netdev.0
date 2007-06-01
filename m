From: Doug Chapman <doug.chapman@hp.com>
Subject: Re: [PATCH] e1000: disable polling before registering netdevice
Date: Fri, 01 Jun 2007 18:37:48 -0400
Message-ID: <1180737468.26001.1.camel@athlon>
References: <20070601172239.12639.92139.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org
To: Auke Kok <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:41127 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759451AbXFAWid (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Jun 2007 18:38:33 -0400
In-Reply-To: <20070601172239.12639.92139.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2007-06-01 at 10:22 -0700, Auke Kok wrote:
> To assure the symmetry of poll enable/disable in up/down, we should
> initialize the netdevice to be poll_disabled at load time. Doing
> this after register_netdevice leaves us open to another race, so
> lets move all the netif_* calls above register_netdevice so the
> stack starts out how we expect it to be.
> 
> Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
> Cc: Herbert Xu <herbert@gondor.apana.org.au>
> Cc: Doug Chapman <doug.chapman@hp.com>


I tested this on my HP Integrity systems and it looks good.

thanks,

- Doug


