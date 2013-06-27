From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] loopback: set pkt_type to PACKET_HOST explicitly
Date: Thu, 27 Jun 2013 01:50:55 -0700 (PDT)
Message-ID: <20130627.015055.473002057056365894.davem@davemloft.net>
References: <20130626093751.GB8524@valinux.co.jp>
	<20130626.152930.1401552744929449732.davem@davemloft.net>
	<20130627052938.GD8524@valinux.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	murphy.mccauley@gmail.com, pshelar@nicira.com, jesse@nicira.com,
	dev@openvswitch.org
To: yamahata@valinux.co.jp
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52308 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752959Ab3F0Iu6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Jun 2013 04:50:58 -0400
In-Reply-To: <20130627052938.GD8524@valinux.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Isaku Yamahata <yamahata@valinux.co.jp>
Date: Thu, 27 Jun 2013 14:29:38 +0900

> So you mean like this patch?  The callers of dev_forward_skb() are
> only veth, macvlan and l2tp, which seem fine with this change.

Yes, it is what I was suggesting.
