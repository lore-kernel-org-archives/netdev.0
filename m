From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 00/19] IPv6 NDISC Updates
Date: Mon, 21 Jan 2013 13:35:27 -0500 (EST)
Message-ID: <20130121.133527.1399553564620986529.davem@davemloft.net>
References: <50FD712C.1050703@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40825 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751134Ab3AUSff (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jan 2013 13:35:35 -0500
In-Reply-To: <50FD712C.1050703@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date: Tue, 22 Jan 2013 01:47:40 +0900

> This series of changes basically clean up NDISC logic,
> especially on sender side.

This series looks great, applied.

In patch #4 you add a check on rd_len such that the option is only
constructed if rd_len is non-zero, I'd like you to enhance this so
that it's easier to understand.

I can't convince myself either that rd_len can never be zero, or that
when it is zero we do not still put the uninitialized 'opt' into the
packet and out on the wire.

Using either assertions of descriptive comments, explain why all of
these problems will not arise.

Thanks.
