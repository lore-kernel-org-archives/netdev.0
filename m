From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 3/3] macvlan: allow in-kernel modules to create and manage macvlan devices
Date: Fri, 27 Nov 2009 23:19:53 +0100
Message-ID: <200911272319.53825.arnd@arndb.de>
References: <20091113195201.11184.25766.stgit@mimic.site> <20091113195529.11184.19011.stgit@mimic.site>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org,
	alacrityvm-devel@lists.sourceforge.net,
	linux-kernel@vger.kernel.org, bridge@lists.linux-foundation.org
To: Patrick Mullaney <pmullaney@novell.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.187]:61770 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751012AbZK0WTw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Nov 2009 17:19:52 -0500
In-Reply-To: <20091113195529.11184.19011.stgit@mimic.site>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 13 November 2009, Patrick Mullaney wrote:
> @@ -318,7 +318,7 @@ static struct lock_class_key macvlan_netdev_addr_lock_key;
>  #define MACVLAN_FEATURES \
>         (NETIF_F_SG | NETIF_F_ALL_CSUM | NETIF_F_HIGHDMA | NETIF_F_FRAGLIST | \
>          NETIF_F_GSO | NETIF_F_TSO | NETIF_F_UFO | NETIF_F_GSO_ROBUST | \
> -        NETIF_F_TSO_ECN | NETIF_F_TSO6)
> +        NETIF_F_TSO_ECN | NETIF_F_TSO6 | NETIF_F_GRO)
>  
>  #define MACVLAN_STATE_MASK \
>         ((1<<__LINK_STATE_NOCARRIER) | (1<<__LINK_STATE_DORMANT))

This hunk looks like it should be a separate patch, because we will
want to have this independently of the rest. I have taken it into
a series I'm preparing for a new posting of macvtap based on the
current net-next tree with my bridge mode changes. I also have
your patch 1 (the fixed version) and 2 in there. It's currently
work in progress, but if you are interested, take a look at [1].

	Arnd <><

[1] http://git.kernel.org/?p=linux/kernel/git/arnd/playground.git;a=shortlog;h=refs/heads/macvlan
