From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 net-next 0/5] net: better lockdep annotations
Date: Thu, 09 Jun 2016 13:29:01 -0700 (PDT)
Message-ID: <20160609.132901.1816146583763940729.davem@davemloft.net>
References: <1465483515-10821-1-git-send-email-edumazet@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dsa@cumulusnetworks.com,
	eric.dumazet@gmail.com
To: edumazet@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50029 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750756AbcFIU3H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jun 2016 16:29:07 -0400
In-Reply-To: <1465483515-10821-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>
Date: Thu,  9 Jun 2016 07:45:10 -0700

> Introduction of qdisc->running seqcount added lockdep false positives.
> 
> While chasing the bug, it came to me that we had a lot of copies of the
> same stuff in virtual drivers.
> 
> This patch series has the qdisc->running fix (considers that a trylock
> is attempted in lockdep terminology), and adds a generic helper so
> that we no longer have to patch many virtual drivers when a new per-device
> or per-qdisc lock is added.
> 
> Thanks to David Ahern for reporting the issue and testing my patches :)

Indeed :)

Applied, thanks Eric.
