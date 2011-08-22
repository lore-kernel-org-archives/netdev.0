From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 0/2] pktgen: Clone skb to avoid corruption of skbs in
 ndo_start_xmit methods (v3)
Date: Mon, 22 Aug 2011 18:33:34 +0100
Message-ID: <1314034414.2803.18.camel@bwh-desktop>
References: <1311105179-26408-1-git-send-email-nhorman@tuxdriver.com>
	 <1311696338-4739-1-git-send-email-nhorman@tuxdriver.com>
	 <1313593637.2776.9.camel@bwh-desktop>
	 <20110822002641.GA2550@neilslaptop.think-freely.org>
	 <1314029857.2803.6.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:16689 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752618Ab1HVRdh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Aug 2011 13:33:37 -0400
In-Reply-To: <1314029857.2803.6.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2011-08-22 at 17:17 +0100, Ben Hutchings wrote:
[...]
> b. The flag means 'safe to send shared skbs in the way ptkgen does', and
> the restrictions this places on the user and driver should be specified.

We could specify something like:

        The ndo_start_xmit operation for this interface either does not
        modify the given skb or modifies it idempotently. A single skb
        may be transmitted repeatedly on a single queue of this
        interface, but not on multiple queues or on multiple interfaces.

Does that look correct?

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

