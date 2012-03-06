From: David Miller <davem@davemloft.net>
Subject: Re: [RFC][PATCH 0/3] TCP connection repair (v2)
Date: Tue, 06 Mar 2012 16:14:38 -0500 (EST)
Message-ID: <20120306.161438.1544478436564514191.davem@davemloft.net>
References: <4F55DEDE.1090602@parallels.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tj@kernel.org, eric.dumazet@gmail.com
To: xemul@parallels.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:39766 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1031371Ab2CFVOo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Mar 2012 16:14:44 -0500
In-Reply-To: <4F55DEDE.1090602@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@parallels.com>
Date: Tue, 06 Mar 2012 13:54:38 +0400

> Attempt #2 with transparent TCP connection hijacking.

This looks a lot better, the TCP_CLOSE state check makes it more clear
how this is going to be used.

Please fix up the indentation in patch #2.

+		if (!capable(CAP_SYS_ADMIN) || !(sk->sk_state == TCP_CLOSE ||
+					sk->sk_state == TCP_ESTABLISHED))

And once you sort out the details of the ->{syn,fin} bit in the fake headers
added to the repair queues you can resubmit this.

Thanks.
