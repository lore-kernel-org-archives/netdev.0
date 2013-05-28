From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v5 0/2] MPLS: Add limited GSO support
Date: Mon, 27 May 2013 22:51:31 -0700 (PDT)
Message-ID: <20130527.225131.2103824917751166166.davem@davemloft.net>
References: <1369378972-22728-1-git-send-email-horms@verge.net.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dev@openvswitch.org, netdev@vger.kernel.org, jesse@nicira.com,
	pshelar@nicira.com, jarno.rajahalme@nsn.com,
	eric.dumazet@gmail.com, maze@google.com
To: horms@verge.net.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37735 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932868Ab3E1Fvc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 May 2013 01:51:32 -0400
In-Reply-To: <1369378972-22728-1-git-send-email-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Horman <horms@verge.net.au>
Date: Fri, 24 May 2013 16:02:50 +0900

> In the case where a non-MPLS packet is received and an MPLS stack is
> added it may well be the case that the original skb is GSO but the
> NIC used for transmit does not support GSO of MPLS packets.
> 
> The aim of this short series is to provide GSO in software for MPLS packets
> whose skbs are GSO.

Looks good, and harmless, applied, thanks!
