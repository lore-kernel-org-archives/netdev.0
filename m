From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] ax25: Stop using sock->sk_protinfo.
Date: Sat, 27 Jun 2015 19:32:38 -0700 (PDT)
Message-ID: <20150627.193238.1449363675975197869.davem@davemloft.net>
References: <20150625.061907.1258416005349767495.davem@davemloft.net>
	<20150626214305.GB13920@linux-mips.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kda@linux-powerpc.org, netdev@vger.kernel.org, edumazet@google.com
To: ralf@linux-mips.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33228 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752039AbbF1Ccl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Jun 2015 22:32:41 -0400
In-Reply-To: <20150626214305.GB13920@linux-mips.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ralf Baechle <ralf@linux-mips.org>
Date: Fri, 26 Jun 2015 23:43:05 +0200

> I have the big solution my queue which combines struct sock with ax25_cb
> into struct ax25_sock but that's more complex because currently there is
> the possibility for an ax25_cb to be created by an incoming connection
> request even without a socket.

I initially tried morphing ax25_cb into ax25_sock but I stopped when
I saw the anonymous ax25_cb objects.

I really don't think it's worth it, FWIW...
