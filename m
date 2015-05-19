From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 2/2] tcp: don't over-send F-RTO probes
Date: Tue, 19 May 2015 16:37:26 -0400 (EDT)
Message-ID: <20150519.163726.39558547040538869.davem@davemloft.net>
References: <1431977505-15014-1-git-send-email-ycheng@google.com>
	<1431977505-15014-2-git-send-email-ycheng@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ncardwell@google.com
To: ycheng@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47937 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751024AbbESUh1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 May 2015 16:37:27 -0400
In-Reply-To: <1431977505-15014-2-git-send-email-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuchung Cheng <ycheng@google.com>
Date: Mon, 18 May 2015 12:31:45 -0700

> After sending the new data packets to probe (step 2), F-RTO may
> incorrectly send more probes if the next ACK advances SND_UNA and
> does not sack new packet. However F-RTO RFC 5682 probes at most
> once. This bug may cause sender to always send new data instead of
> repairing holes, inducing longer HoL blocking on the receiver for
> the application.
> 
> Signed-off-by: Yuchung Cheng <ycheng@google.com>
> Signed-off-by: Neal Cardwell <ncardwell@google.com>

Applied.
