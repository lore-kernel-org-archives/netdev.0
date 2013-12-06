From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bonding: fix packets_per_slave showing
Date: Fri, 06 Dec 2013 15:17:27 -0500 (EST)
Message-ID: <20131206.151727.1150209377430566302.davem@davemloft.net>
References: <1386239818-7408-1-git-send-email-nikolay@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net, fubar@us.ibm.com,
	vfalico@redhat.com
To: nikolay@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42117 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754156Ab3LFUR3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Dec 2013 15:17:29 -0500
In-Reply-To: <1386239818-7408-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@redhat.com>
Date: Thu,  5 Dec 2013 11:36:58 +0100

> There's an issue when showing the value of packets_per_slave due to
> using signed integer. The value may be < 0 and thus not put through
> reciprocal_value() before showing. This patch makes it use unsigned
> integer when showing it.
> 
> CC: Andy Gospodarek <andy@greyhouse.net>
> CC: Jay Vosburgh <fubar@us.ibm.com>
> CC: Veaceslav Falico <vfalico@redhat.com>
> CC: David S. Miller <davem@davemloft.net>
> Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>

Applied, thanks.
