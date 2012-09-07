From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] udp: increment UDP_MIB_INERRORS if copy failed
Date: Fri, 07 Sep 2012 12:59:45 -0400 (EDT)
Message-ID: <20120907.125945.1731223999630461002.davem@davemloft.net>
References: <1346924084.2484.12.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sbohrer@rgmadvisors.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39133 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752349Ab2IGQ7r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Sep 2012 12:59:47 -0400
In-Reply-To: <1346924084.2484.12.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 06 Sep 2012 11:34:44 +0200

> From: Eric Dumazet <edumazet@google.com>
> 
> In UDP recvmsg(), we miss an increase of UDP_MIB_INERRORS if the copy
> of skb to userspace failed for whatever reason.
> 
> Reported-by: Shawn Bohrer <sbohrer@rgmadvisors.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied to 'net', since this significantly helps diagnose problems.
