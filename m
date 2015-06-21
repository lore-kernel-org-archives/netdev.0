From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] sock_diag: fetch source port from inet_sock
Date: Sun, 21 Jun 2015 10:17:32 -0700 (PDT)
Message-ID: <20150621.101732.640058888707620388.davem@davemloft.net>
References: <1434553150-8750-1-git-send-email-kraig@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com
To: kraig@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46773 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755833AbbFURFp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Jun 2015 13:05:45 -0400
In-Reply-To: <1434553150-8750-1-git-send-email-kraig@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Craig Gallek <kraig@google.com>
Date: Wed, 17 Jun 2015 10:59:10 -0400

> When an inet_sock is destroyed, its source port (sk_num) is set to
> zero as part of the unhash procedure.  In order to supply a source
> port as part of the NETLINK_SOCK_DIAG socket destruction broadcasts,
> the source port number must be read from inet_sport instead.
> 
> Tested: ss -E
> Signed-off-by: Craig Gallek <kraig@google.com>

Applied but it seems very hackish and not very long term maintainable
to do things this way.
