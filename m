From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/6] tcp: congestion control refactoring
Date: Thu, 14 Jan 2016 23:55:59 -0500 (EST)
Message-ID: <20160114.235559.1259846948104957501.davem@davemloft.net>
References: <1452815014-601-1-git-send-email-ycheng@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ycheng@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54585 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751141AbcAOE4F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Jan 2016 23:56:05 -0500
In-Reply-To: <1452815014-601-1-git-send-email-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuchung Cheng <ycheng@google.com>
Date: Thu, 14 Jan 2016 15:43:28 -0800

> This patch set refactors the sequence of congestion control,
> loss recovery, and transmission logic in TCP ack processing.
> 
> The design goal is to decouple and sequence them in the following order:
> 
>   0. ACK accounting: free or tag sent packets [unchanged]
> 
>   1. loss recovery: identify lost/ecn packets and update congestion state
> 
>   2. congestion control: up/down cwnd and pacing rate based on (1)
> 
>   3. transmission: send new or retransmit old based on (1) and (2)
> 
> This refactoring makes the cwnd changes more clear because it's done
> in one place. The packet accounting is also more robust especially
> for connections that do not support SACK. Patch 1-4 and 6 are
> refactoring and patch 5 improves TCP performance under reordering.

As the net-next tree is closed right now, please resubmit this series
when it opens back up.

Thank you.
