From: David Miller <davem@davemloft.net>
Subject: Re: [NET]: Fix breakage, use ip_hdr() for DF check in ip_forward
Date: Sun, 25 Mar 2007 13:27:32 -0700 (PDT)
Message-ID: <20070325.132732.35663469.davem@davemloft.net>
References: <11746948063923-git-send-email-jheffner@psc.edu>
	<11746948061847-git-send-email-jheffner@psc.edu>
	<20070325133731.GH521@postel.suug.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jheffner@psc.edu, netdev@vger.kernel.org
To: tgraf@suug.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33620
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752313AbXCYU1d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Mar 2007 16:27:33 -0400
In-Reply-To: <20070325133731.GH521@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Thomas Graf <tgraf@suug.ch>
Date: Sun, 25 Mar 2007 15:37:31 +0200

> The patch [NET] Move DF check to ip_forward broke net-2.6.22 as
> skb->nh has been renamed to skb->network_header. Use ip_hdr().
> 
> Signed-off-by: Thomas Graf <tgraf@suug.ch>

Thanks Thomas.

John I'm extremely irritated.  You send me which is obviouly a feature
patch, which I'm obviously NOT going to apply to the current upstream
for 2.6.21, which is only accepting bug fixes, yet you do not test
compile your work and build your patches against my net-2.6.22 tree
which is where such feature patches are going to get applied?

That's just irresponsible, please don't do that again or you'll
be on my shit list for a good long while.
