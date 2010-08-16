From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH net-next-2.6] netlink: netlink_recvmsg() fix
Date: Mon, 16 Aug 2010 07:25:51 +0200
Message-ID: <1281936351.3683.1.camel@jlt3.sipsolutions.net>
References: <1281710115.3760.27.camel@jlt3.sipsolutions.net>
	 <1281710887.4470.78.camel@edumazet-laptop>
	 <1281712433.2116.15.camel@jlt3.sipsolutions.net>
	 <20100814.223722.116371746.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from he.sipsolutions.net ([78.46.109.217]:38945 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751807Ab0HPFZ5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Aug 2010 01:25:57 -0400
In-Reply-To: <20100814.223722.116371746.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2010-08-14 at 22:37 -0700, David Miller wrote:
> From: Johannes Berg <johannes@sipsolutions.net>
> Date: Fri, 13 Aug 2010 17:13:53 +0200
> 
> > On Fri, 2010-08-13 at 16:48 +0200, Eric Dumazet wrote:
> > 
> >> I assume reverting 1235f504aaba removes these errors ?
> > 
> > I haven't tried yet, but it only happened very recently and I didn't
> > find any other candidate -- the error always points to
> > wireless_send_event too.
> 
> Please test with the commit reverted and let us know if it helps.
> 
> The current situation is worse than what we were trying to fix
> in that commit, so if a revert fixes your problem then as Eric
> said we should do that first.

I haven't gotten around to it, but Kalle had been running into the same
issue and said reverting it fixed it:

http://article.gmane.org/gmane.linux.kernel.wireless.general/54492

johannes

