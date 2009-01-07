From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] powerpc: cleanup from l64 to ll64 change: drivers/net
Date: Tue, 06 Jan 2009 16:46:35 -0800 (PST)
Message-ID: <20090106.164635.27664644.davem@davemloft.net>
References: <20090107114006.336cfad0.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org, santil@us.ibm.com,
	raisch@de.ibm.com, themann@de.ibm.com, tklein@de.ibm.com
To: sfr@canb.auug.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33937
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752681AbZAGAqd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Jan 2009 19:46:33 -0500
In-Reply-To: <20090107114006.336cfad0.sfr@canb.auug.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Wed, 7 Jan 2009 11:40:06 +1100

> These are powerpc specific drivers.
> 
> Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
> ---
>  drivers/net/ehea/ehea_main.c |    8 ++++----
>  drivers/net/ehea/ehea_qmr.c  |   18 +++++++++---------
>  drivers/net/ibmveth.c        |   16 ++++++++--------
>  drivers/net/iseries_veth.c   |    2 +-
>  4 files changed, 22 insertions(+), 22 deletions(-)
> 
> This patch on its own will generate several warnings - it depends on
> the actual l64 to ll64 patch that is pending in the powerpc queue.  It
> may be easier for someone to ack this and for it to actually be fed
> through the powerpc tree.

Feeding it through the powerpc tree works for me:

Acked-by: David S. Miller <davem@davemloft.net>
