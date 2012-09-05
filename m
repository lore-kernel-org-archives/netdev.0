From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 1/3] tcp: add generic netlink support for tcp_metrics
Date: Wed, 05 Sep 2012 15:17:33 -0400 (EDT)
Message-ID: <20120905.151733.643669381328617078.davem@davemloft.net>
References: <1346792597-2427-1-git-send-email-ja@ssi.bg>
	<1346792597-2427-2-git-send-email-ja@ssi.bg>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@vyatta.com
To: ja@ssi.bg
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43895 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754648Ab2IETRf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Sep 2012 15:17:35 -0400
In-Reply-To: <1346792597-2427-2-git-send-email-ja@ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julian Anastasov <ja@ssi.bg>
Date: Wed,  5 Sep 2012 00:03:15 +0300

> 	Add support for genl "tcp_metrics". No locking
> is changed, only that now we can unlink and delete
> entries after grace period. We implement get/del for
> single entry and dump to support show/flush filtering
> in user space. Del without address attribute causes
> flush for all addresses, sadly under genl_mutex.
> 
> v2:
> - remove rcu_assign_pointer as suggested by Eric Dumazet,
> it is not needed because there are no other writes under lock
> - move the flushing code in tcp_metrics_flush_all
> 
> v3:
> - remove synchronize_rcu on flush as suggested by Eric Dumazet
> 
> Signed-off-by: Julian Anastasov <ja@ssi.bg>

Looks great, applied to net-next, thanks Julian.
