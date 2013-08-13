From: Julia Lawall <julia.lawall@lip6.fr>
Subject: question about drivers/net/ethernet/jme.{c,h}
Date: Tue, 13 Aug 2013 18:33:45 +0200 (CEST)
Message-ID: <alpine.DEB.2.02.1308131831250.2263@hadrien>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: cooldavid@cooldavid.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail3-relais-sop.national.inria.fr ([192.134.164.104]:36912
	"EHLO mail3-relais-sop.national.inria.fr" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757916Ab3HMQeF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Aug 2013 12:34:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I wonder what is the point of the macro NETIF_NAPI_SET?  It has only one
definition, and it just transfers its arguments directly to the more
common function netif_napi_add.  The fact that the definition of the macro
contains a semicolon also makes the use of NETIF_NAPI_SET not look like a
normal function call.

thanks,
julia
