From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/6] tcp: congestion control refactoring
Date: Sun, 07 Feb 2016 14:10:59 -0500 (EST)
Message-ID: <20160207.141059.791432860051131378.davem@davemloft.net>
References: <1454437989-3842-1-git-send-email-ycheng@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ycheng@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35615 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754517AbcBGTLC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Feb 2016 14:11:02 -0500
In-Reply-To: <1454437989-3842-1-git-send-email-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuchung Cheng <ycheng@google.com>
Date: Tue,  2 Feb 2016 10:33:03 -0800

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

This series looks really nice, applied, thanks!
