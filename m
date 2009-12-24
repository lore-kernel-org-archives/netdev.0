From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH] pktgen: ndo_start_xmit can return NET_XMIT_xxx
 values
Date: Wed, 23 Dec 2009 22:03:09 -0800 (PST)
Message-ID: <20091223.220309.98892207.davem@davemloft.net>
References: <20091223233951.17072.93304.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: robert@herjulf.net, netdev@vger.kernel.org, gospo@redhat.com,
	john.r.fastabend@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47293
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751457AbZLXGDK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Dec 2009 01:03:10 -0500
In-Reply-To: <20091223233951.17072.93304.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Wed, 23 Dec 2009 15:39:52 -0800

> From: John Fastabend <john.r.fastabend@intel.com>
> 
> This updates pktgen so that it does not decrement skb->users
> when it receives valid NET_XMIT_xxx values.  These are now
> valid return values from ndo_start_xmit in net-next-2.6.
> They also indicate the skb has been consumed.
> 
> This fixes pktgen to work correctly with vlan devices.
> 
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied, thanks.
