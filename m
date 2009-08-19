From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] ibm_newemac: emac_close() needs to call
 netif_carrier_off()
Date: Wed, 19 Aug 2009 16:48:56 -0700
Message-ID: <20090819164856.2ed8b666@s6510>
References: <20090819210000.D56AB254211@localhost>
	<20090819141136.74f5c266@s6510>
	<20090819.143403.27319428.davem@davemloft.net>
	<fc21faff0908191440p5db84f79h8bb8a73501facae1@mail.gmail.com>
	<fc21faff0908191532i2de570a1g1a6674bf5fe64a05@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, benh@kernel.crashing.org,
	netdev@vger.kernel.org
To: Petri Gynther <pgynther@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:40029 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752564AbZHSXtB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Aug 2009 19:49:01 -0400
In-Reply-To: <fc21faff0908191532i2de570a1g1a6674bf5fe64a05@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 19 Aug 2009 15:32:41 -0700
Petri Gynther <pgynther@google.com> wrote:

> Stephen,
> 
> I think your suggestion of adding netif_running() check to
> bond_check_dev_link() is valid and a good fix to the bonding driver.
> We can do this in a separate patch.
> 
> However, I think that the change to ibm_newemac: emac_close() is
> needed as well. ibm_newemac netdevs should not return
> netif_carrier_ok() == TRUE when they have been shut down.

I concur. Fixing the possible problems in both places is best.

