From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] af_packet: when sending ethernet frames, parse
 header for skb->protocol
Date: Thu, 01 Aug 2013 18:12:08 -0700 (PDT)
Message-ID: <20130801.181208.804928209108880255.davem@davemloft.net>
References: <1375291667-9572-2-git-send-email-phil@nwl.cc>
	<20130731.173017.624144247713296239.davem@davemloft.net>
	<20130801103509.GB27563@orbit.nwl.cc>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: phil@nwl.cc
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56587 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753376Ab3HBBMJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Aug 2013 21:12:09 -0400
In-Reply-To: <20130801103509.GB27563@orbit.nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Phil Sutter <phil@nwl.cc>
Date: Thu, 1 Aug 2013 12:35:09 +0200

> Is it OK to rely on eth_type_trans() setting skb->dev after all?

Yes, it is.
