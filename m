From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 6/9] Consolidate the xxx_frag_destroy
Date: Mon, 15 Oct 2007 02:39:34 -0700 (PDT)
Message-ID: <20071015.023934.56795147.davem@davemloft.net>
References: <470F6EAE.60308@openvz.org>
	<470F74C2.9060301@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org, devel@openvz.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39911
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754009AbXJOJja (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Oct 2007 05:39:30 -0400
In-Reply-To: <470F74C2.9060301@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pavel Emelyanov <xemul@openvz.org>
Date: Fri, 12 Oct 2007 17:21:06 +0400

> To make in possible we need to know the exact frag queue
> size for inet_frags->mem management and two callbacks:
> 
>  * to destoy the skb (optional, used in conntracks only)
>  * to free the queue itself (mandatory, but later I plan to 
>    move the allocation and the destruction of frag_queues 
>    into the common place, so this callback will most likely
>    be optional too).
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Applied.
