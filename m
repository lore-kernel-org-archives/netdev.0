From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: account SYN-ACK timeouts & retransmissions
Date: Sun, 17 Jan 2010 19:09:55 -0800 (PST)
Message-ID: <20100117.190955.150527197.davem@davemloft.net>
References: <201001132307.59472.opurdila@ixiacom.com>
	<20100114.020322.168786392.davem@davemloft.net>
	<201001172127.03713.opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mpyatkovskiy@ixiacom.com
To: opurdila@ixiacom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56341
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751984Ab0ARDJq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Jan 2010 22:09:46 -0500
In-Reply-To: <201001172127.03713.opurdila@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Octavian Purdila <opurdila@ixiacom.com>
Date: Sun, 17 Jan 2010 21:27:03 +0200

> [net-next PATCH v2] tcp: account SYN-ACK timeouts & retransmissions
> 
> Currently we don't increment SYN-ACK timeouts & retransmissions
> although we do increment the same stats for SYN. We seem to have lost
> the SYN-ACK accounting with the introduction of tcp_syn_recv_timer
> (commit 2248761e in the netdev-vger-cvs tree).
> 
> This patch fixes this issue. In the process we also rename the v4/v6
> syn/ack retransmit functions for clarity. We also add a new
> request_socket operations (syn_ack_timeout) so we can keep code in
> inet_connection_sock.c protocol agnostic.
> 
> Signed-off-by: Octavian Purdila <opurdila@ixiacom.com>

Applied, thanks Octavian.
