From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [NET]: Add netif_tx_lock
Date: Mon, 05 Jun 2006 21:50:11 -0700
Message-ID: <adalksanb0c.fsf@cisco.com>
References: <20060531.170908.46214247.davem@davemloft.net>
	<20060601002525.GA19220@gondor.apana.org.au>
	<20060601111503.GA16097@gondor.apana.org.au>
	<20060605.213250.85688925.davem@davemloft.net>
	<adapshmnbam.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: herbert@gondor.apana.org.au, mchan@broadcom.com, jgarzik@pobox.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-5.cisco.com ([171.68.10.87]:34072 "EHLO
	sj-iport-5.cisco.com") by vger.kernel.org with ESMTP
	id S932074AbWFFEuT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Jun 2006 00:50:19 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <adapshmnbam.fsf@cisco.com> (Roland Dreier's message of "Mon, 05 Jun 2006 21:44:01 -0700")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

    Roland> Sorry, I haven't followed this thread closely.  Can you
    Roland> expand on what the bug in ipoib's multicast locking is?

You know, looking at the ipoib code, I can't even recreate why
xmit_lock is taken in the set_multicast_list method anyway, or how it
works at all -- it seems set_multicast_list will always be called with
xmit_lock already held.  What the heck is going on?

 - R.
