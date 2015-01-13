From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net-next v2 2/3] netlink: eliminate nl_sk_hash_lock
Date: Tue, 13 Jan 2015 00:08:51 +0000
Message-ID: <20150113000851.GC16617@casper.infradead.org>
References: <1421045544-13670-1-git-send-email-ying.xue@windriver.com>
 <1421045544-13670-3-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Ying Xue <ying.xue@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:48456 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751489AbbAMAIy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Jan 2015 19:08:54 -0500
Content-Disposition: inline
In-Reply-To: <1421045544-13670-3-git-send-email-ying.xue@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/12/15 at 02:52pm, Ying Xue wrote:
> As rhashtable_lookup_compare_insert() can guarantee the process
> of search and insertion is atomic, it's safe to eliminate the
> nl_sk_hash_lock. After this, object insertion or removal will
> be protected with per bucket lock on write side while object
> lookup is guarded with rcu read lock on read side.
> 
> Signed-off-by: Ying Xue <ying.xue@windriver.com>
> Cc: Thomas Graf <tgraf@suug.ch>

LGTM now, nice!

Acked-by: Thomas Graf <tgraf@suug.ch>
