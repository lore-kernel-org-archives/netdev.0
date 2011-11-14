From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Don't allow sharing of tx skbs on xen-netfront
Date: Mon, 14 Nov 2011 14:27:16 -0500 (EST)
Message-ID: <20111114.142716.615003966880410697.davem@davemloft.net>
References: <1321298544-16434-1-git-send-email-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeremy.fitzhardinge@citrix.com,
	konrad.wilk@oracle.com, xen-devel@lists.xensource.com
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:51275 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753955Ab1KNT2a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Nov 2011 14:28:30 -0500
In-Reply-To: <1321298544-16434-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman <nhorman@tuxdriver.com>
Date: Mon, 14 Nov 2011 14:22:24 -0500

> It was pointed out to me recently that the xen-netfront driver can't safely
> support shared skbs on transmit, since, while it doesn't maintain skb state
> directly, it does pass a pointer to the skb to the hypervisor via a list, and
> the hypervisor may expect the contents of the skb to remain stable.  Clearing
> the IFF_TX_SKB_SHARING flag after the call to alloc_etherdev to make it safe.
> 
> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>

Please put an appropriate prefix into the subject lines of your patch
submissions.  In this case "[PATCH] xen-netfront: ..." would be appropriate.

I've been letting you get away with this for the past few weeks and I've
decided that it's your turn to start getting this right :-)
