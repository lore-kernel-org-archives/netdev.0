From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] rps: tcp: fix rps_sock_flow_table table updates
Date: Thu, 03 Jun 2010 20:07:21 -0700 (PDT)
Message-ID: <20100603.200721.59663365.davem@davemloft.net>
References: <1275591838.2533.37.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: therbert@google.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44940
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756931Ab0FDDHL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jun 2010 23:07:11 -0400
In-Reply-To: <1275591838.2533.37.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 03 Jun 2010 21:03:58 +0200

> I believe a moderate SYN flood attack can corrupt RFS flow table
> (rps_sock_flow_table), making RPS/RFS much less effective.
 ...
> This patch moves sock_rps_save_rxhash() to a sock locked section,
> and only for non LISTEN sockets.

This looks good to me.

Tom, please review.
