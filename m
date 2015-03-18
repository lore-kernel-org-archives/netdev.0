From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/6] inet: tcp listener refactoring, part 12
Date: Tue, 17 Mar 2015 22:03:38 -0400 (EDT)
Message-ID: <20150317.220338.748443107477137734.davem@davemloft.net>
References: <1426642351-26098-1-git-send-email-edumazet@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: edumazet@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55454 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752963AbbCRCDn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Mar 2015 22:03:43 -0400
In-Reply-To: <1426642351-26098-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>
Date: Tue, 17 Mar 2015 18:32:25 -0700

> By adding a pointer back to listener, we are preparing synack rtx
> handling to no longer be governed by listener keepalive timer,
> as this is the most problematic source of contention on listener
> spinlock. Note that TCP FastOpen had such pointer anyway, so we
> make it generic.

Looks good, patch applied, thanks.

In patch #6 an extraneous final empty line was added to an inline
function in net/request_sock.h, which I removed while applying this
series.
