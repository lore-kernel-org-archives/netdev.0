From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] fib_trie: call fib_table_flush_external under
 RTNL
Date: Wed, 11 Mar 2015 16:46:47 -0400 (EDT)
Message-ID: <20150311.164647.889372246681481012.davem@davemloft.net>
References: <20150310183555.GB1743@kria>
	<1426017834-24209-1-git-send-email-sd@queasysnail.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, alexander.h.duyck@redhat.com,
	sfeldma@gmail.com
To: sd@queasysnail.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51614 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751702AbbCKUqs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Mar 2015 16:46:48 -0400
In-Reply-To: <1426017834-24209-1-git-send-email-sd@queasysnail.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sabrina Dubroca <sd@queasysnail.net>
Date: Tue, 10 Mar 2015 21:03:54 +0100

> Move rtnl_lock() before the call to fib4_rules_exit so that
> fib_table_flush_external is called under RTNL.
> 
> Fixes: 104616e74e0b ("switchdev: don't support custom ip rules, for now")
> Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>

Applied, thanks a lot.
