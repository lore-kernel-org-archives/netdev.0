From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] netlink: don't hold mutex in rcu callback when
 releasing mmapd ring
Date: Tue, 21 Jul 2015 22:23:22 -0700 (PDT)
Message-ID: <20150721.222322.1270246148178121431.davem@davemloft.net>
References: <1437489230-23542-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kirill@shutemov.name,
	cwang@twopensource.com, tgraf@suug.ch, kaber@trash.net
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36766 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754272AbbGVFXX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jul 2015 01:23:23 -0400
In-Reply-To: <1437489230-23542-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Tue, 21 Jul 2015 16:33:50 +0200

> Kirill A. Shutemov says:
> 
> This simple test-case trigers few locking asserts in kernel:
 ...
> Cong Wang says:
> 
> We can't hold mutex lock in a rcu callback, [..]
> 
> Thomas Graf says:
> 
> The socket should be dead at this point. It might be simpler to
> add a netlink_release_ring() function which doesn't require
> locking at all.
> 
> Reported-by: "Kirill A. Shutemov" <kirill@shutemov.name>
> Diagnosed-by: Cong Wang <cwang@twopensource.com>
> Suggested-by: Thomas Graf <tgraf@suug.ch>
> Signed-off-by: Florian Westphal <fw@strlen.de>

Applied, thanks everyone.
