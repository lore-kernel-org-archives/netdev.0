From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] cls_u32: use skb_copy_bits() to dereference data safely
Date: Wed, 02 Jun 2010 06:43:16 -0700 (PDT)
Message-ID: <20100602.064316.218079399.davem@davemloft.net>
References: <20100602.054520.228955151.davem@davemloft.net>
	<AANLkTil0sLvcHRTcGTfYYlCYzDH07sl7xgk6EcjL99cl@mail.gmail.com>
	<1275485797.3545.4.camel@bigi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xiaosuo@gmail.com, netdev@vger.kernel.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47156
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755211Ab0FBNnJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jun 2010 09:43:09 -0400
In-Reply-To: <1275485797.3545.4.camel@bigi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: jamal <hadi@cyberus.ca>
Date: Wed, 02 Jun 2010 09:36:37 -0400

> On Wed, 2010-06-02 at 21:14 +0800, Changli Gao wrote:
> 
> 
>> Maybe skb_header_pointer() is lighter.
> 
> A little worse than skb_copy_bits(). In any case, this change is going
> to hurt.

Umm, Jamal what are you talking about?

Using skb_header_pointer(), if the offset is in range, there is no
change from today other than a comparison.

If it is not in range, we use skb_copy_bits().  It's only for the
case where we have to fetch the value from the fragmented part
of the SKB.
