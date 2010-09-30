From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2.6] myri10ge: DCA update (resubmit)
Date: Wed, 29 Sep 2010 19:49:01 -0700 (PDT)
Message-ID: <20100929.194901.191389574.davem@davemloft.net>
References: <4CA23038.3030808@myri.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, loic@myri.com
To: gallatin@myri.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34999
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753196Ab0I3Csl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Sep 2010 22:48:41 -0400
In-Reply-To: <4CA23038.3030808@myri.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Gallatin <gallatin@myri.com>
Date: Tue, 28 Sep 2010 14:13:12 -0400

> This patch contains the following DCA improvements to myri10ge:
> 
> 1) Finally move myri10ge to use dca3 API
> 
> 2) Disable PCIe relaxed ordering when enabling DCA on
>     myri10ge.  This provides a performance boost on Nehalem
>     based Xeons
> 
> 3) Make sure to properly initialize NIC's DCA state when it is
> enabled,
>     rather than giving the NIC a bogus tag (0) and waiting for
>     the first received packet to trigger an update.  Not using a
>     real tag can cause hardware exceptions on some motherboards
>     when a CPU socket is empty.
> 
> 3) Always update the cached CPU when our interrupt affinity changes
>     so as to avoid excessive calls to dca3_get_tag()
> 
> Signed-off-by: Andrew Gallatin <gallatin@myri.com>
> Signed-off-by: Loic Prylli <loic@myri.com>

Applied.
