From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next] net: use jump_label to shortcut RPS if not
 setup
Date: Thu, 17 Nov 2011 17:04:42 -0500 (EST)
Message-ID: <20111117.170442.1731100546322591134.davem@davemloft.net>
References: <1321535606.2751.35.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<1321565689.2444.5.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, therbert@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:33558 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752240Ab1KQWEp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Nov 2011 17:04:45 -0500
In-Reply-To: <1321565689.2444.5.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 17 Nov 2011 22:34:49 +0100

> I wonder if we could use this jump_label infrastructure to shortcut
> expensive netfilter nf_hook_slow() / nf_iterate on empty
> tables/chains...

That would be nice, I can't see why it wouldn't be possible.
