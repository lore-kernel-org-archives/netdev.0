From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] vlan: adds drops accounting
Date: Thu, 03 Sep 2009 20:11:31 -0700 (PDT)
Message-ID: <20090903.201131.194103894.davem@davemloft.net>
References: <4A9F9CD4.7040408@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58054
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932683AbZIDDLQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Sep 2009 23:11:16 -0400
In-Reply-To: <4A9F9CD4.7040408@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 03 Sep 2009 12:39:16 +0200

> Its hard to tell if vlans are dropping frames, since
> every frame given to vlan_???_start_xmit() functions
> is accounted as fully transmitted by lower device.
> 
> We can test dev_queue_xmit() return values to
> properly account for dropped frames.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.

But, how inappropriate would it be to keep doing the accounting
but pass the status back to the caller?  Or will that screw up
the qdisc running engine?
