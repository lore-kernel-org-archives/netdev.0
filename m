From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] netlink: add NETLINK_NO_ENOBUFS socket flag
Date: Mon, 23 Mar 2009 14:09:08 +0100
Message-ID: <49C789F4.4050906@trash.net>
References: <20090323093353.14253.76823.stgit@Decadence> <49C77971.8080302@trash.net> <49C77C89.1010108@netfilter.org> <49C77D1D.7010204@trash.net> <49C77FC8.2010803@netfilter.org> <49C78382.9000600@trash.net> <49C78922.7050104@netfilter.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:38390 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753075AbZCWNJP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Mar 2009 09:09:15 -0400
In-Reply-To: <49C78922.7050104@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pablo Neira Ayuso wrote:
> Patrick McHardy wrote:
>> But I think some notification or other way to notice whats happening
>> is needed for userspace, otherwise it can neither report not handle
>> this in any way.
> 
> Hm, I see. I think that we can increase sk_drop like in the UDP code
> when the NETLINK_NO_ENOBUFS flag is set. We can display it in the
> netlink /proc entry. Would you be OK with this?

Yes, something like that seems OK.

