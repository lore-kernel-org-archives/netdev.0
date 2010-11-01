From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: check queue_index from sock is valid for device
Date: Mon, 01 Nov 2010 12:56:05 -0700 (PDT)
Message-ID: <20101101.125605.28797776.davem@davemloft.net>
References: <alpine.DEB.1.00.1011011249590.5368@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52186
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753113Ab0KATzl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Nov 2010 15:55:41 -0400
In-Reply-To: <alpine.DEB.1.00.1011011249590.5368@pokey.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <therbert@google.com>
Date: Mon, 1 Nov 2010 12:53:32 -0700 (PDT)

> In dev_pick_tx recompute the queue index if the value stored in the
> socket is greater than or equal to the number of real queues for the
> device.  The saved index in the sock structure is not guaranteed to
> be appropriate for the egress device (this could happen on a route
> change or in presence of tunnelling).  The result of the queue index
> being bad would be to return a bogus queue (crash could prersumably
> follow).
> 
> Signed-off-by: Tom Herbert <therbert@google.com>

Looks good, applied, thanks Tom.
