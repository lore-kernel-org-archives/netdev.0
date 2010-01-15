From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Remove unused function - skb_frag_add_head
Date: Fri, 15 Jan 2010 00:40:05 -0800 (PST)
Message-ID: <20100115.004005.128351897.davem@davemloft.net>
References: <20100115053205.31534.85551.sendpatchset@krkumar2.in.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: krkumar2@in.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56422
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753722Ab0AOIj4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jan 2010 03:39:56 -0500
In-Reply-To: <20100115053205.31534.85551.sendpatchset@krkumar2.in.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Krishna Kumar <krkumar2@in.ibm.com>
Date: Fri, 15 Jan 2010 11:02:05 +0530

> From: Krishna Kumar <krkumar2@in.ibm.com>
> 
> Remove unused function - skb_frag_add_head
> 
> Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>

It rounds out the abstractions for accessing the fragment list.

All uses of the frag list need to be converted to these things
so that we can finally change sk_buff to use struct list_head
instead of a by-hand linked list.

So I'm not applying this.
