From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netlink: change return-value logic of
 netlink_broadcast()
Date: Thu, 05 Feb 2009 23:57:00 -0800 (PST)
Message-ID: <20090205.235700.01016634.davem@davemloft.net>
References: <20090204201303.15404.76336.stgit@Decadence>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kaber@trash.net
To: pablo@netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35525
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752751AbZBFH5E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Feb 2009 02:57:04 -0500
In-Reply-To: <20090204201303.15404.76336.stgit@Decadence>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pablo Neira Ayuso <pablo@netfilter.org>
Date: Wed, 04 Feb 2009 21:13:03 +0100

> Currently, netlink_broadcast() reports errors to the caller if no
> messages at all were delivered:
> 
> 1) If, at least, one message has been delivered correctly, returns 0.
> 2) Otherwise, if no messages at all were delivered due to skb_clone()
>    failure, return -ENOBUFS.
> 3) Otherwise, if there are no listeners, return -ESRCH.
> 
> With this patch, the caller knows if the delivery of any of the
> messages to the listeners have failed:
 ...
> Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>

Looks great, applied, thanks Pablo.
