From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv4: ip_forward: perform skb->pkt_type check
 at the beginning
Date: Wed, 12 Feb 2014 09:44:36 -0500 (EST)
Message-ID: <20140212.094436.2293140925107427190.davem@davemloft.net>
References: <1392192632-24513-1-git-send-email-kda@linux-powerpc.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: kda@linux-powerpc.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54426 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751218AbaBLOok (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Feb 2014 09:44:40 -0500
In-Reply-To: <1392192632-24513-1-git-send-email-kda@linux-powerpc.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Denis Kirjanov <kda@linux-powerpc.org>
Date: Wed, 12 Feb 2014 12:10:32 +0400

> +    /* that should never happen */
> +    if (skb->pkt_type != PACKET_HOST)
> +        goto drop;
> +

At a minimum, this is not formatted properly.  You are using spaces
instead of TAB characters.
