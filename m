From: David Miller <davem@davemloft.net>
Subject: Re: RFC: on [ab]use of skb->cb by VLAN code
Date: Mon, 30 Jul 2007 19:06:21 -0700 (PDT)
Message-ID: <20070730.190621.13770511.davem@davemloft.net>
References: <1185843556.5162.8.camel@localhost>
	<20070730.183337.27784025.davem@davemloft.net>
	<1185847324.5162.31.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: greearb@candelatech.com, kaber@trash.net, netdev@vger.kernel.org,
	mcarlson@broadcom.com
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54642
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757588AbXGaCGW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jul 2007 22:06:22 -0400
In-Reply-To: <1185847324.5162.31.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: jamal <hadi@cyberus.ca>
Date: Mon, 30 Jul 2007 22:02:04 -0400

> I came across the issue because i used cb in batching to store transient
> state which is used between qdisc dequeueing and hardware enqueueing
> (looked and smelled legit to me).

Right, dequeue->device should be OK and doesn't work because of
the VLAN issue.

