From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [NET] warn when accounting an skb that already has a
 destructor
Date: Mon, 05 May 2008 00:20:06 -0700 (PDT)
Message-ID: <20080505.002006.225975612.davem@davemloft.net>
References: <1209925940.3655.17.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: johannes@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40227
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752267AbYEEHUG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 May 2008 03:20:06 -0400
In-Reply-To: <1209925940.3655.17.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes@sipsolutions.net>
Date: Sun, 04 May 2008 20:32:20 +0200

> This makes the networking layer warn when something tries to
> charge an skb to a socket that already is charged to another
> socket (or has a destructor from somewhere else.)
> 
> Signed-off-by: Johannes Berg <johannes@sipsolutions.net>

I completely agree that this a correct assertion, that
absolutely should never happen in the current tree.

But if we are going to do this, I'm pretty sure we'll
need to uninline these two routines.

I'll leave it up to you, if you think it's still worthwhile
with the uninlining, please resubmit :-)
