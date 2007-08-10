From: David Miller <davem@davemloft.net>
Subject: Re: [patch 25/28] netconsole: Support multiple logging targets
Date: Fri, 10 Aug 2007 15:33:51 -0700 (PDT)
Message-ID: <20070810.153351.21236141.davem@davemloft.net>
References: <200708102112.l7ALC8VN009454@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, satyam@infradead.org,
	k-keiichi@bx.jp.nec.com, mpm@selenic.com
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34761
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1763657AbXHJWdu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Aug 2007 18:33:50 -0400
In-Reply-To: <200708102112.l7ALC8VN009454@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: akpm@linux-foundation.org
Date: Fri, 10 Aug 2007 14:12:07 -0700

> From: Satyam Sharma <satyam@infradead.org>
> 
> Based upon initial work by Keiichi Kii <k-keiichi@bx.jp.nec.com>.
> 
> This patch introduces support for multiple targets, independent of
> CONFIG_NETCONSOLE_DYNAMIC -- this is useful even in the default case and
> (including the infrastructure introduced in previous patches) doesn't really
> add too many bytes to module text.  All the complexity (and size) comes with
> the dynamic reconfigurability / userspace interface patch, and so it's
> plausible users may want to keep this enabled but that disabled (say to avoid
> a dependency on CONFIG_CONFIGFS_FS too).
> 
> Also update documentation to mention the use of ";" separator to specify
> multiple logging targets in the boot/module option string.
> 
> Brief overview:
> 
> We maintain a target_list (and corresponding lock).  Get rid of the static
> "default_target" and introduce allocation and release functions for our
> netconsole_target objects (but keeping sure to preserve previous behaviour
> such as default values).  During init_netconsole(), ";" is used as the
> separator to identify multiple target specifications in the boot/module option
> string.  The target specifications are parsed and netpolls setup.  During
> exit, the target_list is torn down and all items released.
> 
> Signed-off-by: Satyam Sharma <satyam@infradead.org>
> Signed-off-by: Keiichi Kii <k-keiichi@bx.jp.nec.com>
> Cc: Matt Mackall <mpm@selenic.com>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

Applied to net-2.6.24, thanks!
