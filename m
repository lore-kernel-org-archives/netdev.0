From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6.26 3/6][SOCK][NETNS]: Add the percpu prot_inuse
 counter in the struct net.
Date: Mon, 31 Mar 2008 20:19:14 -0700 (PDT)
Message-ID: <20080331.201914.69779071.davem@davemloft.net>
References: <47F0D5F3.6070500@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devel@openvz.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47815
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753470AbYDADTO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Mar 2008 23:19:14 -0400
In-Reply-To: <47F0D5F3.6070500@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@openvz.org>
Date: Mon, 31 Mar 2008 16:15:47 +0400

> Such an accounting would cost us two more dereferences to get the
> percpu variable from the struct net, so I make sock_prot_inuse_get
> and _add calls work differently depending on CONFIG_NET_NS - without
> it old optimized routines are used.
> 
> The per-cpu counter for init_net is prepared in core_initcall, so
> that even af_inet, that starts as fs_initcall, will already have the
> init_net prepared.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Applied.
