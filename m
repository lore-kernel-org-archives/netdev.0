From: David Miller <davem@davemloft.net>
Subject: Re: pskb_copy() in tcp_transmit_skb()
Date: Tue, 13 Sep 2011 12:34:28 -0400 (EDT)
Message-ID: <20110913.123428.544295943856661409.davem@davemloft.net>
References: <4E6F2275.2050902@cn.fujitsu.com>
	<201109131355.55588.christoph.paasch@uclouvain.be>
	<CAL4Wiio=2MO2u53dvU1fqjeKqgQuVBmgDpZeVROMaZYcPPDpzA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: christoph.paasch@uclouvain.be, gaofeng@cn.fujitsu.com,
	netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:33074 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753662Ab1IMQfv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Sep 2011 12:35:51 -0400
In-Reply-To: <CAL4Wiio=2MO2u53dvU1fqjeKqgQuVBmgDpZeVROMaZYcPPDpzA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 13 Sep 2011 14:02:17 +0200

> I suggest you read dev_queue_xmit_nit() : Every xmit packet can be
> cloned right here.

Right, any packet that has been sent in the past might now be
cloned.
