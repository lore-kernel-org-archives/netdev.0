From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/8] ethoc: prevent overflow of rx counter
Date: Wed, 24 Nov 2010 11:36:28 -0800 (PST)
Message-ID: <20101124.113628.70208708.davem@davemloft.net>
References: <1290606058-26703-1-git-send-email-jonas@southpole.se>
	<1290606058-26703-5-git-send-email-jonas@southpole.se>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jonas@southpole.se
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33232
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754641Ab0KXTgD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Nov 2010 14:36:03 -0500
In-Reply-To: <1290606058-26703-5-git-send-email-jonas@southpole.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jonas Bonn <jonas@southpole.se>
Date: Wed, 24 Nov 2010 14:40:54 +0100

> Rewind cur_rx to prevent it from overflowing.
> 
> Signed-off-by: Jonas Bonn <jonas@southpole.se>
...
> +	/* Prevent overflow of priv->cur_rx by rewinding it */	

Trailing whitespace, also please integrate the feedback from Ben
and Eric Dumazet about making this computation less expensive.
