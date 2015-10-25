From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] af_unix: do not report POLLOUT on listeners
Date: Sun, 25 Oct 2015 06:45:54 -0700 (PDT)
Message-ID: <20151025.064554.969566293457384990.davem@davemloft.net>
References: <562A631B.6060207@oracle.com>
	<1445622453.22974.180.camel@edumazet-glaptop2.roam.corp.google.com>
	<1445623156.22974.186.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Alan.Burlison@oracle.com, Casper.Dik@oracle.com,
	viro@ZenIV.linux.org.uk, stephen@networkplumber.org,
	netdev@vger.kernel.org, dholland-tech@netbsd.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51972 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751092AbbJYN3T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Oct 2015 09:29:19 -0400
In-Reply-To: <1445623156.22974.186.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 23 Oct 2015 10:59:16 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> poll(POLLOUT) on a listener should not report fd is ready for
> a write().
> 
> This would break some applications using poll() and pfd.events = -1,
> as they would not block in poll()
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Reported-by: Alan Burlison <Alan.Burlison@oracle.com>
> Tested-by: Eric Dumazet <edumazet@google.com>

Applied, thanks Eric.
