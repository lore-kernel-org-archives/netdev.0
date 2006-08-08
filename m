From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] avoid unnecessary alignement overhead in skb->data
 allocation.
Date: Mon, 07 Aug 2006 17:41:42 -0700 (PDT)
Message-ID: <20060807.174142.88474584.davem@davemloft.net>
References: <20060807073103.GA11283@2ka.mipt.ru>
	<20060807073919.GA5582@gondor.apana.org.au>
	<4807377b0608071709j26da1092la20f1589c7b90df7@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, johnpol@2ka.mipt.ru,
	netdev@vger.kernel.org, chris.leech@gmail.com,
	jesse.brandeburg@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:18574
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932464AbWHHAl7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Aug 2006 20:41:59 -0400
To: jesse.brandeburg@gmail.com
In-Reply-To: <4807377b0608071709j26da1092la20f1589c7b90df7@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Jesse Brandeburg" <jesse.brandeburg@gmail.com>
Date: Mon, 7 Aug 2006 17:09:39 -0700

> also, eth_type_trans wants skb->data to point to header, which would
> require us to memcpy data from a page back to skb->data.

You merely would need to call pskb_may_pull() right before invoking
eth_type_trans.  Meeting that functions expectations with a non-linear
SKB is not brain surgery. :-)

