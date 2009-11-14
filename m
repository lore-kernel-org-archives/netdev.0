From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sctp: Set socket source address when additing first
 transport
Date: Fri, 13 Nov 2009 19:57:24 -0800 (PST)
Message-ID: <20091113.195724.05973595.davem@davemloft.net>
References: <1257879454-31661-1-git-send-email-vladislav.yasevich@hp.com>
	<1257976477-31326-1-git-send-email-vladislav.yasevich@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org
To: vladislav.yasevich@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35596
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757377AbZKND5I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Nov 2009 22:57:08 -0500
In-Reply-To: <1257976477-31326-1-git-send-email-vladislav.yasevich@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich <vladislav.yasevich@hp.com>
Date: Wed, 11 Nov 2009 16:54:37 -0500

> Recent commits
> 	sctp: Get rid of an extra routing lookup when adding a transport
> and
> 	sctp: Set source addresses on the association before adding transports
> 
> changed when routes are added to the sctp transports.  As such,
> we didn't set the socket source address correctly when adding the first
> transport.  The first transport is always the primary/active one, so
> when adding it, set the socket source address.  This was causing
> regression failures in SCTP tests.
> 
> Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>

Applied.
