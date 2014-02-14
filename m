From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] packet: check for ndo_select_queue during queue
 selection
Date: Fri, 14 Feb 2014 00:40:48 -0500 (EST)
Message-ID: <20140214.004048.616136663605863975.davem@davemloft.net>
References: <1392311935-10275-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mathias.kretschmer@fokus.fraunhofer.de, netdev@vger.kernel.org,
	brouer@redhat.com
To: dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53232 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751242AbaBNFku (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Feb 2014 00:40:50 -0500
In-Reply-To: <1392311935-10275-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>
Date: Thu, 13 Feb 2014 18:18:55 +0100

> The original pktgen scenario for which PACKET_QDISC_BYPASS was
> designed for is still intact with this change anyway. We think

I guess you have no intention of using this feature on bnx2x, ixgbe,
or mlx4 devices then?  That covers a rather large component of gigabit
ethernet devices out there, doesn't it?

They both hook up an ndo_select_queue method.
