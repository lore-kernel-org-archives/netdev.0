From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [patch net-next v2 2/2] net: introduce netif_addr_lock_nested()
 and call if when appropriate
Date: Mon, 9 Jan 2012 19:07:08 +0000
Message-ID: <1326136028.2725.0.camel@bwh-desktop>
References: <1326125915-2711-1-git-send-email-jpirko@redhat.com>
	 <1326125915-2711-2-git-send-email-jpirko@redhat.com>
	 <20120109163654.GC2114@minipsycho.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <davem@davemloft.net>,
	<eric.dumazet@gmail.com>
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:62735 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751013Ab2AITHO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jan 2012 14:07:14 -0500
In-Reply-To: <20120109163654.GC2114@minipsycho.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-01-09 at 17:36 +0100, Jiri Pirko wrote:
> dev_uc_sync() and dev_mc_sync() are acquiring netif_addr_lock for
> destination device of synchronization. Since netif_addr_lock is already
> held at the time for source device, this triggers depmod deathlock
> warning.
[...]

I think you mean '...lockdep deadlock warning'?

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
