From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCHSET] IPv4 FIB configuration rework
Date: Tue, 08 Aug 2006 21:38:22 +0200
Message-ID: <20060808193822.104083150@postel.suug.ch>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:38785 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S1030270AbWHHTqr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Aug 2006 15:46:47 -0400
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Replaces the rather ugly struct kern_rta + rtmsg with a new
struct fib_config while converting everything to the new netlink
api. Simplifies the FIB module interface quite a bit and allows
changing internals while keeping a stable netlink interface.

Gets rid of things like passing on netlink_skb_parms all around
the fib code etc.

Also fixes some memory corruptions that could be triggered via
netlink messages, not sure which would actually lead to an oops
though.

