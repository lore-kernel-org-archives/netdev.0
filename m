From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] sysctl: accept_redirects do not change when
 disabling ip_forwarding
Date: Fri, 09 Aug 2013 01:20:48 -0700 (PDT)
Message-ID: <20130809.012048.2254462226856062154.davem@davemloft.net>
References: <b560b71eadb678de8a573f18a10f840bf0a68df0.1375979491.git.ffusco@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ffusco@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41773 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S967682Ab3HIIUv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Aug 2013 04:20:51 -0400
In-Reply-To: <b560b71eadb678de8a573f18a10f840bf0a68df0.1375979491.git.ffusco@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Francesco Fusco <ffusco@redhat.com>
Date: Fri,  9 Aug 2013 10:08:59 +0200

> The sysctl behavior in the current kernel in not in synch with what is stated
> in the ip-sysctl.txt documentation file. When disabling ip_forwarding the
> net.ipv4.conf.all.accept_redirects is enabled without warning even if all the
> accept_redirects were set to zero.

The behavior is intentional because a router should not respond to redirects.

Fix the documentation file instead, thank you.
