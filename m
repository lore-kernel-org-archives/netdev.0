From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4 net-next] tcp: replace cnt & rtt with struct in
 pkts_acked()
Date: Wed, 11 May 2016 15:28:25 -0400 (EDT)
Message-ID: <20160511.152825.1524234534935127740.davem@davemloft.net>
References: <1462986133-4101863-1-git-send-email-brakmo@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-team@fb.com, ncardwell@google.com,
	eric.dumazet@gmail.com, ycheng@google.com
To: brakmo@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51727 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751462AbcEKT21 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 May 2016 15:28:27 -0400
In-Reply-To: <1462986133-4101863-1-git-send-email-brakmo@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lawrence Brakmo <brakmo@fb.com>
Date: Wed, 11 May 2016 10:02:13 -0700

> Replace 2 arguments (cnt and rtt) in the congestion control modules'
> pkts_acked() function with a struct. This will allow adding more
> information without having to modify existing congestion control
> modules (tcp_nv in particular needs bytes in flight when packet
> was sent).
> 
> As proposed by Neal Cardwell in his comments to the tcp_nv patch.
> 
> Signed-off-by: Lawrence Brakmo <brakmo@fb.com>
> Acked-by: Yuchung Cheng <ycheng@google.com>

Looks a lot better, applied, thanks!
