From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: addrconf: clear IPv6 addresses and routes when
 losing link
Date: Tue, 26 Oct 2010 10:47:10 -0700 (PDT)
Message-ID: <20101026.104710.232747902.davem@davemloft.net>
References: <AANLkTin-u_bZj6_wpoV6fNaLg81JbFN0EvhNrA6wX6SG@mail.gmail.com>
	<20101026.102145.246528067.davem@davemloft.net>
	<AANLkTi=P80OUBSy3xCt_qOjPGTwNjrtFL1iLJnkc9joq@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: brian.haley@hp.com, shemminger@vyatta.com, netdev@vger.kernel.org
To: lorenzo@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48112
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752527Ab0JZRqq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Oct 2010 13:46:46 -0400
In-Reply-To: <AANLkTi=P80OUBSy3xCt_qOjPGTwNjrtFL1iLJnkc9joq@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lorenzo Colitti <lorenzo@google.com>
Date: Tue, 26 Oct 2010 10:37:53 -0700

> So when the link comes back, we'd have to wait for all RAs to come in
> (there could be multiple routers on a link, each announcing different
> prefixes), and when this is all done, compare the list of addresses to
> the prefixes that are currently on the link and delete the ones that
> don't match. We'd have to do the same with default routers and /64
> routes to all the link prefixes.

Why would you do this when there are link layer indications that
we are attached to a different network?

The only thing missing is a new device notification type, some code to
generate it in the wireless subsystem, and an ipv6 handler to zap the
addresses when received.

Please think out of the box for a second, thanks :-)
