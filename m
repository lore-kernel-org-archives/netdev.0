From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [Patch 2/2] mlx4: add dynamic LRO disable support
Date: Thu, 03 Jun 2010 13:37:02 +0100
Message-ID: <1275568622.2870.89.camel@localhost>
References: <20100603034303.5305.55552.sendpatchset@localhost.localdomain>
	 <20100603034312.5305.61000.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, herbert.xu@redhat.com, nhorman@redhat.com,
	sgruszka@redhat.com, davem@davemloft.net
To: Amerigo Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:49297 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752129Ab0FCMhH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jun 2010 08:37:07 -0400
In-Reply-To: <20100603034312.5305.61000.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2010-06-02 at 23:39 -0400, Amerigo Wang wrote:
> This patch adds dynamic LRO diable support for mlx4 net driver.
> It also fixes a bug of mlx4, which checks NETIF_F_LRO flag in rx
> path without rtnl lock.
[...]

Is that flag test actually unsafe - and if so, how is testing num_lro
any better?  Perhaps access to net_device::features should be wrapped
with ACCESS_ONCE() to ensure that reads and writes are atomic.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

