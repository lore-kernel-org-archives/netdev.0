From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3] [NET] Move DF check to ip_forward
Date: Sat, 24 Mar 2007 21:17:18 -0700 (PDT)
Message-ID: <20070324.211718.48528824.davem@davemloft.net>
References: <11746948063923-git-send-email-jheffner@psc.edu>
	<11746948061847-git-send-email-jheffner@psc.edu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jheffner@psc.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49553
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S965054AbXCYERT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Mar 2007 00:17:19 -0400
In-Reply-To: <11746948061847-git-send-email-jheffner@psc.edu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: John Heffner <jheffner@psc.edu>
Date: Fri, 23 Mar 2007 20:06:45 -0400

> Do fragmentation check in ip_forward, similar to ipv6 forwarding.  Also add
> a debug printk in the DF check in ip_fragment since we should now never
> reach it.
> 
> Signed-off-by: John Heffner <jheffner@psc.edu>

I don't think this debugging log message makes sense considering
netfilter can potentially do interesting things to the packet.

Therefore I applied your patch without the log message, we can
discuss it's merits seperately as I like the rest of this patch.

Thanks.
