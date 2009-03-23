From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH] netlink: add NETLINK_NO_ENOBUFS socket flag
Date: Mon, 23 Mar 2009 14:05:38 +0100
Message-ID: <49C78922.7050104@netfilter.org>
References: <20090323093353.14253.76823.stgit@Decadence> <49C77971.8080302@trash.net> <49C77C89.1010108@netfilter.org> <49C77D1D.7010204@trash.net> <49C77FC8.2010803@netfilter.org> <49C78382.9000600@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:44882 "EHLO us.es"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751992AbZCWNFu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Mar 2009 09:05:50 -0400
In-Reply-To: <49C78382.9000600@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick McHardy wrote:
> But I think some notification or other way to notice whats happening
> is needed for userspace, otherwise it can neither report not handle
> this in any way.

Hm, I see. I think that we can increase sk_drop like in the UDP code
when the NETLINK_NO_ENOBUFS flag is set. We can display it in the
netlink /proc entry. Would you be OK with this?

-- 
"Los honestos son inadaptados sociales" -- Les Luthiers
