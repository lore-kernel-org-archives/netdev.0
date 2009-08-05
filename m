From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -mmotm] xfrm4: fix build when SYSCTLs are disabled
Date: Tue, 04 Aug 2009 20:20:29 -0700 (PDT)
Message-ID: <20090804.202029.71546749.davem@davemloft.net>
References: <200908042125.n74LP9qY018119@imap1.linux-foundation.org>
	<20090804185430.fb8e8561.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org,
	netdev@vger.kernel.org
To: randy.dunlap@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50342
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933408AbZHEDUV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Aug 2009 23:20:21 -0400
In-Reply-To: <20090804185430.fb8e8561.randy.dunlap@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Randy Dunlap <randy.dunlap@oracle.com>
Date: Tue, 4 Aug 2009 18:54:30 -0700

> From: Randy Dunlap <randy.dunlap@oracle.com>
> 
> Fix build errors when SYSCTLs are not enabled:
> (.init.text+0x5154): undefined reference to `net_ipv4_ctl_path'
> (.init.text+0x5176): undefined reference to `register_net_sysctl_table'
> xfrm4_policy.c:(.exit.text+0x573): undefined reference to `unregister_net_sysctl_table
> 
> Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>

Applied, thanks Randy.

The ipv6 side has the same issue, I'll fix that part up myself.
