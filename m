From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] sfc: mark state UNINIT after unregister
Date: Mon, 15 Jun 2015 19:55:17 -0700 (PDT)
Message-ID: <20150615.195517.1004965610413006036.davem@davemloft.net>
References: <557F0B1A.2040809@solarflare.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: ecree@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43582 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754095AbbFPCzS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Jun 2015 22:55:18 -0400
In-Reply-To: <557F0B1A.2040809@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Edward Cree <ecree@solarflare.com>
Date: Mon, 15 Jun 2015 18:27:54 +0100

> Without this change, modprobe -r sfc hits the BUG_ON() in
> efx_pci_remove_main().
> 
> Fixes: e7fef9b45ae1 ("sfc: add sysfs entry to control MCDI tracing")
> Reported-by: Jarod Wilson <jarod@redhat.com>
> Reviewed-by: Jarod Wilson <jarod@redhat.com>
> Signed-off-by: Edward Cree <ecree@solarflare.com>

Applied, thanks.
