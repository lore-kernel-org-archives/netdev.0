From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] e1000: disable polling before registering netdevice
Date: Sun, 03 Jun 2007 11:47:46 -0400
Message-ID: <4662E2A2.6050005@garzik.org>
References: <20070601172239.12639.92139.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, doug.chapman@hp.com,
	netdev@vger.kernel.org
To: Auke Kok <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:38297 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752383AbXFCPrz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 3 Jun 2007 11:47:55 -0400
In-Reply-To: <20070601172239.12639.92139.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Auke Kok wrote:
> To assure the symmetry of poll enable/disable in up/down, we should
> initialize the netdevice to be poll_disabled at load time. Doing
> this after register_netdevice leaves us open to another race, so
> lets move all the netif_* calls above register_netdevice so the
> stack starts out how we expect it to be.
> 
> Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
> Cc: Herbert Xu <herbert@gondor.apana.org.au>
> Cc: Doug Chapman <doug.chapman@hp.com>
> ---
> 
>  drivers/net/e1000/e1000_main.c |   11 +++++++----
>  1 files changed, 7 insertions(+), 4 deletions(-)

applied to #upstream-fixes


