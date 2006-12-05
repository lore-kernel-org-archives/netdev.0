From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] [IPV6] RAW: Don't release unlocked sock.
Date: Tue, 05 Dec 2006 13:49:10 -0800 (PST)
Message-ID: <20061205.134910.01049577.davem@davemloft.net>
References: <11653129943938-git-send-email-nakam@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40639
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1759001AbWLEVtE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Dec 2006 16:49:04 -0500
To: nakam@linux-ipv6.org
In-Reply-To: <11653129943938-git-send-email-nakam@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Masahide NAKAMURA <nakam@linux-ipv6.org>
Date: Tue,  5 Dec 2006 19:03:14 +0900

> When user builds IPv6 header and send it through raw socket, kernel
> tries to release unlocked sock. (Kernel log shows
> "BUG: bad unlock balance detected" with enabled debug option.)
> 
> The lock is held only for non-hdrincl sock in this function
> then this patch fix to do nothing about lock for hdrincl one.
> 
> Signed-off-by: Masahide NAKAMURA <nakam@linux-ipv6.org>

Patch applied, thank you very much.
