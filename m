From: David Miller <davem@davemloft.net>
Subject: Re: [GIT PULL] parisc architecture updates for v4.3
Date: Tue, 03 Nov 2015 16:33:24 -0500 (EST)
Message-ID: <20151103.163324.221668446986372734.davem@davemloft.net>
References: <20151025114934.GA11108@ls3530.box>
	<CA+55aFyJyY1FE_1k6Ks-2j4nYr7cbde_KvZ=J3fMUFJG5Okijg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: deller@gmx.de, linux-kernel@vger.kernel.org,
	linux-parisc@vger.kernel.org,
	James.Bottomley@hansenpartnership.com, dave.anglin@bell.net,
	netdev@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47886 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755245AbbKCVd3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Nov 2015 16:33:29 -0500
In-Reply-To: <CA+55aFyJyY1FE_1k6Ks-2j4nYr7cbde_KvZ=J3fMUFJG5Okijg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Tue, 3 Nov 2015 13:01:21 -0800

> David: the issue wrt XPS is this:
> 
>    #define XPS_MIN_MAP_ALLOC ((L1_CACHE_BYTES - sizeof(struct xps_map))   \
>        / sizeof(u16))
> 
> Comments?

The PARISC folks did discuss this with us networking folks...

	http://marc.info/?t=144554413000001&r=1&w=2
