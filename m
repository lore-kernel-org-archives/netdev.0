From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3 0/2] ipv4: per-datagram IP_TOS and IP_TTL
 via sendmsg()
Date: Sat, 28 Sep 2013 15:22:17 -0700 (PDT)
Message-ID: <20130928.152217.259922330845282884.davem@davemloft.net>
References: <cover.1379944641.git.ffusco@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ffusco@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33714 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755225Ab3I1WPR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Sep 2013 18:15:17 -0400
In-Reply-To: <cover.1379944641.git.ffusco@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Francesco Fusco <ffusco@redhat.com>
Date: Tue, 24 Sep 2013 15:43:07 +0200

> There is no way to set the IP_TOS field on a per-packet basis in IPv4, while
> IPv6 has such a mechanism. Therefore one has to fall back to the setsockopt()
> in case of IPv4. 
> 
> Using the existing per-socket option is not convenient particularly in the
> situations where multiple threads have to use the same socket data requiring
> per-thread TOS values. In fact this would involve calling setsockopt() before
> sendmsg() every time.

Series applied, thank you.
