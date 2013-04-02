From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH v2] net: fix smatch warnings inside
 datagram_poll
Date: Tue, 02 Apr 2013 17:01:47 -0400 (EDT)
Message-ID: <20130402.170147.908732674571245473.davem@davemloft.net>
References: <20130402205539.26083.7462.stgit@jekeller-hub.jf.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jacob.e.keller@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47027 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761785Ab3DBVBu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Apr 2013 17:01:50 -0400
In-Reply-To: <20130402205539.26083.7462.stgit@jekeller-hub.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>
Date: Tue,  2 Apr 2013 13:55:40 -0700

> Commit 7d4c04fc170087119727119074e72445f2bb192b ("net: add option to enable
> error queue packets waking select") has an issue due to operator precedence
> causing the bit-wise OR to bind to the sock_flags call instead of the result of
> the terniary conditional. This fixes the *_poll functions to work properly. The
> old code results in "mask |= POLLPRI" instead of what was intended, which is to
> only include POLLPRI when the socket option is enabled.
> 
> Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>

Much better, applied, thanks.
