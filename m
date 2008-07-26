From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] syncookies: Make sure ECN is disabled
Date: Sat, 26 Jul 2008 02:22:33 -0700 (PDT)
Message-ID: <20080726.022233.05670957.davem@davemloft.net>
References: <1216923486-4137-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59745
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751447AbYGZJWd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Jul 2008 05:22:33 -0400
In-Reply-To: <1216923486-4137-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Thu, 24 Jul 2008 20:18:06 +0200

> ecn_ok is not initialized when a connection is established by cookies.
> The cookie syn-ack never sets ECN, so ecn_ok must be set to 0.
> 
> Spotted using ns-3/network simulation cradle simulator and valgrind.
> 
> Signed-off-by: Florian Westphal <fw@strlen.de>

Applied, thanks Florian.
