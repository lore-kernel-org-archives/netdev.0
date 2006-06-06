From: David Miller <davem@davemloft.net>
Subject: Re: [NET]: Add netif_tx_lock
Date: Mon, 05 Jun 2006 21:58:21 -0700 (PDT)
Message-ID: <20060605.215821.69020274.davem@davemloft.net>
References: <20060605.213250.85688925.davem@davemloft.net>
	<adapshmnbam.fsf@cisco.com>
	<adalksanb0c.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, mchan@broadcom.com, jgarzik@pobox.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:15004
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932096AbWFFE6W (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Jun 2006 00:58:22 -0400
To: rdreier@cisco.com
In-Reply-To: <adalksanb0c.fsf@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Roland Dreier <rdreier@cisco.com>
Date: Mon, 05 Jun 2006 21:50:11 -0700

>     Roland> Sorry, I haven't followed this thread closely.  Can you
>     Roland> expand on what the bug in ipoib's multicast locking is?
> 
> You know, looking at the ipoib code, I can't even recreate why
> xmit_lock is taken in the set_multicast_list method anyway, or how it
> works at all -- it seems set_multicast_list will always be called with
> xmit_lock already held.  What the heck is going on?

Isn't the IPOIB driver LLTX and therefore the upper layers are
not taking the xmit_lock?
