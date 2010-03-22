From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH] bonding: flush unicast and multicast
 lists when changing type
Date: Sun, 21 Mar 2010 18:32:20 -0700 (PDT)
Message-ID: <20100321.183220.220048937.davem@davemloft.net>
References: <20100319140023.GC2811@psychotron.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fubar@us.ibm.com,
	bonding-devel@lists.sourceforge.net
To: jpirko@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39751
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753716Ab0CVBb5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Mar 2010 21:31:57 -0400
In-Reply-To: <20100319140023.GC2811@psychotron.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jpirko@redhat.com>
Date: Fri, 19 Mar 2010 15:00:23 +0100

> After the type change, addresses in unicast and multicast lists wouldn't make
> sense, not to mention possible different lenghts. So flush both lists here.
> 
> Note "dev_addr_discard" will be very soon replaced by "dev_mc_flush" (once
> mc_list conversion will be done).
> 
> Signed-off-by: Jiri Pirko <jpirko@redhat.com>

Applied, but maybe these should be EXPORT_SYMBOL_GPL?  Just
asking...
