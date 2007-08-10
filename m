From: David Miller <davem@davemloft.net>
Subject: Re: [patch 23/28] netconsole: Introduce netconsole_target
Date: Fri, 10 Aug 2007 15:32:26 -0700 (PDT)
Message-ID: <20070810.153226.125566176.davem@davemloft.net>
References: <200708102112.l7ALC6pL009448@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, satyam@infradead.org,
	k-keiichi@bx.jp.nec.com, mpm@selenic.com
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59664
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753830AbXHJWc0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Aug 2007 18:32:26 -0400
In-Reply-To: <200708102112.l7ALC6pL009448@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: akpm@linux-foundation.org
Date: Fri, 10 Aug 2007 14:12:05 -0700

> From: Satyam Sharma <satyam@infradead.org>
> 
> Based upon initial work by Keiichi Kii <k-keiichi@bx.jp.nec.com>.
> 
> Introduce a wrapper structure over netpoll to represent logging targets
> configured in netconsole.  This will get extended with other members in
> further patches.
> 
> This is done independent of the (to-be-introduced) NETCONSOLE_DYNAMIC config
> option so that we're able to drastically cut down on the #ifdef complexity of
> final netconsole.c.  Also, struct netconsole_target would be required for
> multiple targets support also, and not just dynamic reconfigurability.
> 
> Signed-off-by: Satyam Sharma <satyam@infradead.org>
> Signed-off-by: Keiichi Kii <k-keiichi@bx.jp.nec.com>
> Cc: Matt Mackall <mpm@selenic.com>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

Applied to net-2.6.24, thanks!
