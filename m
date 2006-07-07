From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] correct dev_alloc_skb kerneldoc
Date: Fri, 07 Jul 2006 16:55:27 -0700 (PDT)
Message-ID: <20060707.165527.77037268.davem@davemloft.net>
References: <20060707090956.GA2543@lst.de>
	<20060707155255.10f2e10f@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hch@lst.de, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:65429
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751280AbWGGXyz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Jul 2006 19:54:55 -0400
To: shemminger@osdl.org
In-Reply-To: <20060707155255.10f2e10f@dxpl.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@osdl.org>
Date: Fri, 7 Jul 2006 15:52:55 -0700

> What is the point of dev_alloc_skb anyway? all it does is add header space.

In stone-age times it actually had specific semantics, but yes today
it is just a synonym.

It's going to be hard to get rid of it, every single network driver
out there references it.
