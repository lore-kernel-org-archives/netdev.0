From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] vlan: use a valid default mtu value for vlan over
 macsec
Date: Sat, 16 Jul 2016 20:16:19 -0700 (PDT)
Message-ID: <20160716.201619.847436342805437808.davem@davemloft.net>
References: <909348fc51775dc7070b528a7492632e53400412.1468511497.git.pabeni@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kaber@trash.net, sd@queasysnail.net
To: pabeni@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:44250 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751909AbcGQDQV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Jul 2016 23:16:21 -0400
In-Reply-To: <909348fc51775dc7070b528a7492632e53400412.1468511497.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paolo Abeni <pabeni@redhat.com>
Date: Thu, 14 Jul 2016 18:00:10 +0200

> macsec can't cope with mtu frames which need vlan tag insertion, and
> vlan device set the default mtu equal to the underlying dev's one.
> By default vlan over macsec devices use invalid mtu, dropping
> all the large packets.
> This patch adds a netif helper to check if an upper vlan device
> needs mtu reduction. The helper is used during vlan devices
> initialization to set a valid default and during mtu updating to
> forbid invalid, too bit, mtu values.
> The helper currently only check if the lower dev is a macsec device,
> if we get more users, we need to update only the helper (possibly
> reserving an additional IFF bit).
> 
> Signed-off-by: Paolo Abeni <pabeni@redhat.com>

Applied and queued up for -stable.
