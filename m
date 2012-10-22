From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: add SYN/data info to TCP_INFO
Date: Mon, 22 Oct 2012 15:16:50 -0400 (EDT)
Message-ID: <20121022.151650.1900715738708866620.davem@davemloft.net>
References: <1350695684-26962-1-git-send-email-ycheng@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ncardwell@google.com, edumazet@google.com, hkchu@google.com,
	netdev@vger.kernel.org
To: ycheng@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:32889 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751811Ab2JVTQw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Oct 2012 15:16:52 -0400
In-Reply-To: <1350695684-26962-1-git-send-email-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuchung Cheng <ycheng@google.com>
Date: Fri, 19 Oct 2012 18:14:44 -0700

> Add a bit TCPI_OPT_SYN_DATA (32) to the socket option TCP_INFO:tcpi_options.
> It's set if the data in SYN (sent or received) is acked by SYN-ACK. Server or
> client application can use this information to check Fast Open success rate.
> 
> Signed-off-by: Yuchung Cheng <ycheng@google.com>

Applied to 'net'
