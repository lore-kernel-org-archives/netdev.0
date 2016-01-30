From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] tcp: avoid cwnd undo after receiving ECN
Date: Fri, 29 Jan 2016 23:04:19 -0800 (PST)
Message-ID: <20160129.230419.1854358229164635050.davem@davemloft.net>
References: <1454109110-32068-1-git-send-email-ycheng@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ncardwell@google.com, edumazet@google.com
To: ycheng@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42966 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751179AbcA3HEU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Jan 2016 02:04:20 -0500
In-Reply-To: <1454109110-32068-1-git-send-email-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuchung Cheng <ycheng@google.com>
Date: Fri, 29 Jan 2016 15:11:50 -0800

> RFC 4015 section 3.4 says the TCP sender MUST refrain from
> reversing the congestion control state when the ACK signals
> congestion through the ECN-Echo flag. Currently we may not
> always do that when prior_ssthresh is reset upon receiving
> ACKs with ECE marks. This patch fixes that.
> 
> Signed-off-by: Yuchung Cheng <ycheng@google.com>
> Signed-off-by: Neal Cardwell <ncardwell@google.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks.
