From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 2/5] net: filter: misc/various cleanups
Date: Thu, 24 Apr 2014 16:00:50 -0400 (EDT)
Message-ID: <20140424.160050.2258325688773881218.davem@davemloft.net>
References: <1398321927-8845-1-git-send-email-dborkman@redhat.com>
	<1398321927-8845-3-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ast@plumgrid.com, netdev@vger.kernel.org
To: dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33903 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751519AbaDXUAy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Apr 2014 16:00:54 -0400
In-Reply-To: <1398321927-8845-3-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>
Date: Thu, 24 Apr 2014 08:45:24 +0200

> +	return __skb_get_poff((struct sk_buff *)(long) ctx);

Please use "unsigned long" when casting pointers to/from integers.
