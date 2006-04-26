From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] netdev: hotplug napi race cleanup
Date: Wed, 26 Apr 2006 02:43:05 -0700 (PDT)
Message-ID: <20060426.024305.122924499.davem@davemloft.net>
References: <20060421102503.4e44eb28@localhost.localdomain>
	<E1FX5zQ-000177-00@gondolin.me.apana.org.au>
	<20060424152341.094b72d8@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, patrakov@ums.usu.ru,
	netdev@vger.kernel.org, akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:62687
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751393AbWDZJnR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Apr 2006 05:43:17 -0400
To: shemminger@osdl.org
In-Reply-To: <20060424152341.094b72d8@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@osdl.org>
Date: Mon, 24 Apr 2006 15:23:41 -0700

> This follows after the earlier two patches.
> 
> Change the initialization of the class device portion of the net device
> to be done earlier, so that any races before registration completes are
> harmless.  Add a mutex to avoid changes to netdevice during the
> class device registration. 
> 
> Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

Once Greg KH puts in the necessary infrastructure patches, I'll put
this one in too.
