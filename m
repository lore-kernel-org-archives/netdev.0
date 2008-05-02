From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [NET] print skb pointer in truesize bug
Date: Fri, 02 May 2008 16:42:26 -0700 (PDT)
Message-ID: <20080502.164226.16189190.davem@davemloft.net>
References: <1209639656.7067.2.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: johannes@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33809
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1759481AbYEBXm1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 May 2008 19:42:27 -0400
In-Reply-To: <1209639656.7067.2.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes@sipsolutions.net>
Date: Thu, 01 May 2008 13:00:56 +0200

> While debugging the mac80211 truesize problem I always wished
> that I knew exactly which skb showed the problem, this makes
> skb_truesize_bug() print out the pointer.
> 
> Signed-off-by: Johannes Berg <johannes@sipsolutions.net>

This information only is useful relative to something else.
Ie. another debugging message that prints out the SKB pointer
and with which you can try and compare things.

I assume you're adding such things while you try to debug
this, and like those local changes, this hack can stay local
to your tree too.
