From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] SCTP: Flush fragment queue when exiting partial
 delivery
Date: Sun, 16 Dec 2007 14:05:58 -0800 (PST)
Message-ID: <20071216.140558.193221004.davem@davemloft.net>
References: <1197788916-2969-1-git-send-email-vladislav.yasevich@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lksctp-developers@lists.sourceforge.net
To: vladislav.yasevich@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42726
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754732AbXLPWGG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Dec 2007 17:06:06 -0500
In-Reply-To: <1197788916-2969-1-git-send-email-vladislav.yasevich@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich <vladislav.yasevich@hp.com>
Date: Sun, 16 Dec 2007 02:08:36 -0500

> At the end of partial delivery, we may have complete messages
> sitting on the fragment queue.  These messages are stuck there
> until a new fragment arrives.  This can comletely stall a
> given association.  When clearing partial delivery state, flush
> any complete messages from the fragment queue and send them on
> their way up.
> 
> Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>

Applied to net-2.6, thanks Vlad!
