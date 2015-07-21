From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net: ratelimit warnings about dst entry refcount
 underflow or overflow
Date: Tue, 21 Jul 2015 00:11:54 -0700 (PDT)
Message-ID: <20150721.001154.1929992682470432462.davem@davemloft.net>
References: <20150717110111.16718.77665.stgit@buzz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com
To: khlebnikov@yandex-team.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55986 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751236AbbGUHLz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jul 2015 03:11:55 -0400
In-Reply-To: <20150717110111.16718.77665.stgit@buzz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Date: Fri, 17 Jul 2015 14:01:11 +0300

> Kernel generates a lot of warnings when dst entry reference counter
> overflows and becomes negative. That bug was seen several times at
> machines with outdated 3.10.y kernels. Most like it's already fixed
> in upstream. Anyway that flood completely kills machine and makes
> further debugging impossible.
> 
> Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>

Applied.
