From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 20/43] drivers/net/hamradio: fix sparse warning:
 context imbalance
Date: Tue, 17 Feb 2009 17:38:18 -0800 (PST)
Message-ID: <20090217.173818.220194179.davem@davemloft.net>
References: <20090214210940.23489.95001.stgit@vmbox.hanneseder.net>
	<20090214213329.24377.28382.stgit@vmbox.hanneseder.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-janitors@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: hannes@hanneseder.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47191
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751660AbZBRBid (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Feb 2009 20:38:33 -0500
In-Reply-To: <20090214213329.24377.28382.stgit@vmbox.hanneseder.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Eder <hannes@hanneseder.net>
Date: Sat, 14 Feb 2009 22:34:52 +0100

> Impact: Attribute functions with __acquires(...) resp. __releases(...).
> 
> Fix this sparse warnings:
>   drivers/net/hamradio/bpqether.c:387:13: warning: context imbalance in 'bpq_seq_start' - wrong count at exit
>   drivers/net/hamradio/bpqether.c:419:13: warning: context imbalance in 'bpq_seq_stop' - unexpected unlock
> 
> Signed-off-by: Hannes Eder <hannes@hanneseder.net>

Applied.
