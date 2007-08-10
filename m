From: David Miller <davem@davemloft.net>
Subject: Re: [patch 21/28] netconsole: Use netif_running() in write_msg()
Date: Fri, 10 Aug 2007 15:30:44 -0700 (PDT)
Message-ID: <20070810.153044.14943816.davem@davemloft.net>
References: <200708102112.l7ALC4RO009442@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, satyam@infradead.org,
	k-keiichi@bx.jp.nec.com, mpm@selenic.com
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59651
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S933977AbXHJWao (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Aug 2007 18:30:44 -0400
In-Reply-To: <200708102112.l7ALC4RO009442@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: akpm@linux-foundation.org
Date: Fri, 10 Aug 2007 14:12:04 -0700

> From: Satyam Sharma <satyam@infradead.org>
> 
> Based upon initial work by Keiichi Kii <k-keiichi@bx.jp.nec.com>.
> 
> Avoid unnecessarily disabling interrupts and calling netpoll_send_udp() if the
> corresponding local interface is not up.
> 
> Signed-off-by: Satyam Sharma <satyam@infradead.org>
> Acked-by: Keiichi Kii <k-keiichi@bx.jp.nec.com>
> Cc: Matt Mackall <mpm@selenic.com>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

Applied to net-2.6.24, thanks!
