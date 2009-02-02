From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] netlink broadcast return value
Date: Mon, 02 Feb 2009 14:05:33 -0800 (PST)
Message-ID: <20090202.140533.121159038.davem@davemloft.net>
References: <4985A4C5.4050908@netfilter.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kaber@trash.net,
	netfilter-devel@vger.kernel.org
To: pablo@netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44229
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1758014AbZBBWFh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Feb 2009 17:05:37 -0500
In-Reply-To: <4985A4C5.4050908@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pablo Neira Ayuso <pablo@netfilter.org>
Date: Sun, 01 Feb 2009 14:33:57 +0100

> In short, I think that the change that I'm proposing would also require
> to fix some netlink_broadcast() clients to skip ENOBUFS errors: they are
> not meaningful for them since they assume that Netlink is unreliable and
> so the return value does not provide any useful information.

I think this analysis is accurate.

Please proceed to do the netlink_broadcast() client changes
and then submit those with this patch and I'll queue it all
up for net-next-2.6

Thanks!
