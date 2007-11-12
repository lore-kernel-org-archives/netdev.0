From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Use list_head-s in inetpeer.c
Date: Mon, 12 Nov 2007 01:42:17 -0800 (PST)
Message-ID: <20071112.014217.62497023.davem@davemloft.net>
References: <4735C11A.7060501@openvz.org>
	<20071110.213107.94486766.davem@davemloft.net>
	<47381573.5020506@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devel@openvz.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54782
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754453AbXKLJmS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Nov 2007 04:42:18 -0500
In-Reply-To: <47381573.5020506@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pavel Emelyanov <xemul@openvz.org>
Date: Mon, 12 Nov 2007 11:57:23 +0300

> No. I remove _two_ pointers unused_next and unused_prevp, and add
> the list_head, which is _two_ pointers as well. I've even checked the
> compilation on both i386 and x86_64 - the sizeof(struct inet_peer) 
> is not changed.
> 
> You must have overlooked the unused_prevp member, because it is 
> declared in the same line as the unused_next. Or I miss something else?

I missed that, please resubmit your patch.

Thanks.
