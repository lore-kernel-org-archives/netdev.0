From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: Fix bug in tcp socket early demux
Date: Sat, 23 Jun 2012 23:23:00 -0700 (PDT)
Message-ID: <20120623.232300.874228666675084293.davem@davemloft.net>
References: <1340509090-2819-1-git-send-email-subramanian.vijay@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
	alexander.h.duyck@intel.com
To: subramanian.vijay@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45080 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750779Ab2FXGXE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Jun 2012 02:23:04 -0400
In-Reply-To: <1340509090-2819-1-git-send-email-subramanian.vijay@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vijay Subramanian <subramanian.vijay@gmail.com>
Date: Sat, 23 Jun 2012 20:38:10 -0700

> The dest port for the call to __inet_lookup_established() in TCP early demux
> code is passed with the wrong endian-ness. This causes the lookup to fail
> leading to early demux not being used.
> 
> Signed-off-by: Vijay Subramanian <subramanian.vijay@gmail.com>

That's what I get for only testing on big-endian :-)

Applied, thanks.
