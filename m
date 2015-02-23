From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: fix tcp_should_expand_sndbuf() to use
 tcp_packets_in_flight()
Date: Sun, 22 Feb 2015 23:07:31 -0500 (EST)
Message-ID: <20150222.230731.1964374887839422637.davem@davemloft.net>
References: <1424457196-3497-1-git-send-email-ncardwell@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ycheng@google.com, edumazet@google.com,
	nanditad@google.com
To: ncardwell@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53251 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751573AbbBWEHd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Feb 2015 23:07:33 -0500
In-Reply-To: <1424457196-3497-1-git-send-email-ncardwell@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neal Cardwell <ncardwell@google.com>
Date: Fri, 20 Feb 2015 13:33:16 -0500

> tcp_should_expand_sndbuf() does not expand the send buffer if we have
> filled the congestion window.
> 
> However, it should use tcp_packets_in_flight() instead of
> tp->packets_out to make this check.
> 
> Testing has established that the difference matters a lot if there are
> many SACKed packets, causing a needless performance shortfall.
> 
> Signed-off-by: Neal Cardwell <ncardwell@google.com>
> Signed-off-by: Yuchung Cheng <ycheng@google.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Signed-off-by: Nandita Dukkipati <nanditad@google.com>

This is a bug in my view, thus applying to 'net'.

Thanks Neal.
