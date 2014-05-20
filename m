From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] vlan: Fix build error wth vlan_get_encap_level()
Date: Tue, 20 May 2014 11:24:54 -0400 (EDT)
Message-ID: <20140520.112454.996974201972683580.davem@davemloft.net>
References: <1400597966-2825-1-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sfr@canb.auug.org.au
To: vyasevic@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37686 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753752AbaETPVY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 May 2014 11:21:24 -0400
In-Reply-To: <1400597966-2825-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich <vyasevic@redhat.com>
Date: Tue, 20 May 2014 10:59:26 -0400

> The new function vlan_get_encap_level() uses vlan_dev_priv()
> which is only conditionally avaialble when VLAN support is
> enabled.  Make vlan_get_encap_level() conditionally available
> as well.
> 
> Fixes: 44a4085538c8 ("bonding: Fix stacked device detection in arp monitoring")
> Reported-by: Stephen Rothwell <sfr@canb.auug.org.au>
> CC: Stephen Rothwell <sfr@canb.auug.org.au>
> Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>

Applied, thanks Vlad.
