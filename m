From: David Miller <davem@davemloft.net>
Subject: Re: [net PATCH v2] gro: Allow tunnel stacking in the case of
 FOU/GUE
Date: Wed, 30 Mar 2016 16:03:20 -0400 (EDT)
Message-ID: <20160330.160320.1141897932138398381.davem@davemloft.net>
References: <20160329215226.12478.3696.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jesse@kernel.org, netdev@vger.kernel.org,
	alexander.duyck@gmail.com, tom@herbertland.com
To: aduyck@mirantis.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37697 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752929AbcC3UDW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Mar 2016 16:03:22 -0400
In-Reply-To: <20160329215226.12478.3696.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <aduyck@mirantis.com>
Date: Tue, 29 Mar 2016 14:55:22 -0700

> This patch should fix the issues seen with a recent fix to prevent
> tunnel-in-tunnel frames from being generated with GRO.  The fix itself is
> correct for now as long as we do not add any devices that support
> NETIF_F_GSO_GRE_CSUM.  When such a device is added it could have the
> potential to mess things up due to the fact that the outer transport header
> points to the outer UDP header and not the GRE header as would be expected.
> 
> Fixes: fac8e0f579695 ("tunnels: Don't apply GRO to multiple layers of encapsulation.")
> Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
> ---
> 
> v2: Dropped switch statements per suggestion of Tom Herbert.

Applied, thanks Alex.
