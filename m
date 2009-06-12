From: David Miller <davem@davemloft.net>
Subject: Re: [RFC net 00/03]: dev_queue_xmit error propagation
Date: Thu, 11 Jun 2009 17:05:12 -0700 (PDT)
Message-ID: <20090611.170512.97427064.davem@davemloft.net>
References: <20090609161658.6730.59754.sendpatchset@x2.localnet>
	<20090611.031852.90563118.davem@davemloft.net>
	<4A3131D6.40807@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51857
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1763559AbZFLAFK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jun 2009 20:05:10 -0400
In-Reply-To: <4A3131D6.40807@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>
Date: Thu, 11 Jun 2009 18:33:26 +0200

> I still need to verify that no drivers are using the raw values for
> the NETDEV_TX codes since NETDEV_TX_LOCKED is using a different
> value with my patch.

Yeah, auditing 500 ->hard_start_xmit implementations is fun.
