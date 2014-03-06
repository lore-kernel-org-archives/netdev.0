From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Improve SO_TIMESTAMPING documentation and fix a
 minor code bug
Date: Thu, 06 Mar 2014 16:18:16 -0500 (EST)
Message-ID: <20140306.161816.601474056305160550.davem@davemloft.net>
References: <ea5365bea8a03800609443cae8dce71eb89e78f4.1393982607.git.luto@amacapital.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: richardcochran@gmail.com, netdev@vger.kernel.org
To: luto@amacapital.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33462 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751645AbaCFVSS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Mar 2014 16:18:18 -0500
In-Reply-To: <ea5365bea8a03800609443cae8dce71eb89e78f4.1393982607.git.luto@amacapital.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Lutomirski <luto@amacapital.net>
Date: Tue,  4 Mar 2014 17:24:10 -0800

> The original documentation was very unclear.
> 
> The code fix is presumably related to the formerly unclear
> documentation: SOCK_TIMESTAMPING_RX_SOFTWARE has no effect on
> __sock_recv_timestamp's behavior, so calling __sock_recv_ts_and_drops
> from sock_recv_ts_and_drops if only SOCK_TIMESTAMPING_RX_SOFTWARE is
> set is pointless.  This should have no user-observable effect.
> 
> Signed-off-by: Andy Lutomirski <luto@amacapital.net>

Applied, thanks Andy.
