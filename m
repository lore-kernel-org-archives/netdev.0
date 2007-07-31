From: David Miller <davem@davemloft.net>
Subject: Re: RFC: on [ab]use of skb->cb by VLAN code
Date: Mon, 30 Jul 2007 18:33:37 -0700 (PDT)
Message-ID: <20070730.183337.27784025.davem@davemloft.net>
References: <1185843556.5162.8.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: greearb@candelatech.com, kaber@trash.net, netdev@vger.kernel.org,
	mcarlson@broadcom.com
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59331
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1760083AbXGaBdn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jul 2007 21:33:43 -0400
In-Reply-To: <1185843556.5162.8.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: jamal <hadi@cyberus.ca>
Date: Mon, 30 Jul 2007 20:59:16 -0400

> This seems like a bad use since there can be a lot of things between 
> a real hardware driver and something that sets a vlan tag (qdiscs come
> to mind).

I understand the concern, but how much qdisc stuff can possibly
happen between those two ->hard_start_xmit() calls and do we
want to support that in any way anyways?

The only alternative I see is to add more things to struct sk_buff
and that's usually very unpopular :-)
