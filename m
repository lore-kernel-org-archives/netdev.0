From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3 2/2] netlink: specify netlink packet
 direction for nlmon
Date: Tue, 31 Dec 2013 13:50:08 -0500 (EST)
Message-ID: <20131231.135008.1712348847039091134.davem@davemloft.net>
References: <1387805756-21121-3-git-send-email-dborkman@redhat.com>
	<52B8770B.60009@6wind.com>
	<52B878D7.4020308@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nicolas.dichtel@6wind.com, netdev@vger.kernel.org,
	darkjames-ws@darkjames.pl
To: dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35336 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756166Ab3LaSuK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Dec 2013 13:50:10 -0500
In-Reply-To: <52B878D7.4020308@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>
Date: Mon, 23 Dec 2013 18:54:31 +0100

> We could entirely remove it as it was e.g. proposed in 2008 [1]
> already if you see any value in that. Eventually it's up to Dave and
> if he likes, I'll be happy to send a patch that removes this define.

Removing user visible defines can break source builds, for example
someone building string tables or auto-generating things to facilitate
accessing these values from languages other than C.

It's harmless, since nobody semantically expects anything of it, but
we have to keep it around.
