From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sctp: set the skb->ip_summed correctly when sending
 over loopback.
Date: Thu, 18 Sep 2008 02:49:07 -0700 (PDT)
Message-ID: <20080918.024907.185077492.davem@davemloft.net>
References: <20080917101130.GU6798@shell>
	<1221681781-1904-1-git-send-email-vladislav.yasevich@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lksctp-developers@lists.sourceforge.net,
	linux-sctp@vger.kernel.org
To: vladislav.yasevich@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:32820
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750954AbYIRJtT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Sep 2008 05:49:19 -0400
In-Reply-To: <1221681781-1904-1-git-send-email-vladislav.yasevich@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich <vladislav.yasevich@hp.com>
Date: Wed, 17 Sep 2008 16:03:01 -0400

> Loopback used to clobber the ip_summed filed which sctp then used
> to figure out if it needed to do checksumming or not.  Now that
> loopback doesn't do that any more, sctp needs to set the ip_summed
> field correctly.
> 
> Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>

That's a silly regression, sorry about that Vlad.

Applied to net-2.6, thanks!
