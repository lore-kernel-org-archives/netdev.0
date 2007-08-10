From: David Miller <davem@davemloft.net>
Subject: Re: [patch 19/28] netconsole: Remove bogus check
Date: Fri, 10 Aug 2007 15:28:26 -0700 (PDT)
Message-ID: <20070810.152826.31751905.davem@davemloft.net>
References: <200708102112.l7ALC3DC009436@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, satyam@infradead.org,
	k-keiichi@bx.jp.nec.com, mpm@selenic.com
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59637
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752587AbXHJW20 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Aug 2007 18:28:26 -0400
In-Reply-To: <200708102112.l7ALC3DC009436@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: akpm@linux-foundation.org
Date: Fri, 10 Aug 2007 14:12:03 -0700

> From: Satyam Sharma <satyam@infradead.org>
> 
> Based upon initial work by Keiichi Kii <k-keiichi@bx.jp.nec.com>.
> 
> The (!np.dev) check in write_msg() is bogus (always false), because: np.dev is
> set by netpoll_setup(), which is called by init_netconsole() before
> register_console(), so write_msg() cannot be triggered unless netpoll_setup()
> successfully set np.dev.  Also np.dev cannot go away from under us, because
> netpoll_setup() grabs us reference on it.  So let's remove the bogus check.
> 
> Signed-off-by: Satyam Sharma <satyam@infradead.org>
> Acked-by: Keiichi Kii <k-keiichi@bx.jp.nec.com>
> Acked-by: Matt Mackall <mpm@selenic.com>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

Applied to net-2.6.24, thanks!
