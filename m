From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/5] tcp: IPv6 support for fastopen server
Date: Tue, 13 May 2014 17:54:11 -0400 (EDT)
Message-ID: <20140513.175411.761191581153166642.davem@davemloft.net>
References: <1399864933-28287-1-git-send-email-ycheng@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ncardwell@google.com, edumazet@google.com, longinus00@gmail.com,
	hkchu@google.com, netdev@vger.kernel.org
To: ycheng@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45639 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752428AbaEMVyN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 May 2014 17:54:13 -0400
In-Reply-To: <1399864933-28287-1-git-send-email-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuchung Cheng <ycheng@google.com>
Date: Sun, 11 May 2014 20:22:08 -0700

> This patch series add IPv6 support for fastopen server. To minimize
> code duplication in IPv4 and IPv6, the current v4 only code is
> refactored and common code is moved into net/ipv4/tcp_fastopen.c.
> 
> Also the current code uses a different function from
> tcp_v4_send_synack() to send the first SYN-ACK in fastopen.
> The new code eliminates this separate function by refactoring the
> child-socket and syn-ack creation code.  After these refactoring
> in the first four patches, we can easily add the fastopen code in
> IPv6 by changing corresponding IPv6 functions.
> 
> Note Fast Open client already supports IPv6. This patch is for
> the server-side (passive open) IPv6 support only.

Series applied to net-next, thanks.
