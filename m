From: Daniel Roesen <dr@cluenet.de>
Subject: Re: [PATCH] ipv6: add special mode forwarding=2 to send RS while
	configured as router
Date: Wed, 24 Nov 2010 19:03:06 +0100
Message-ID: <20101124180306.GA20862@srv03.cluenet.de>
References: <20100903130420.GB28460@bombadil.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org, davem@vger.kernel.org,
	yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.cluenet.de ([195.20.121.100]:45346 "EHLO mail1.cluenet.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752511Ab0KXSNW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Nov 2010 13:13:22 -0500
Content-Disposition: inline
In-Reply-To: <20100903130420.GB28460@bombadil.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Fri, Sep 03, 2010 at 09:04:20AM -0400, Thomas Graf wrote:
> Similar to accepting router advertisement, the IPv6 stack does not send router
> solicitations if forwarding is enabled.
> 
> This patch enables this behavior to be overruled by setting forwarding to the
> special value 2.

Wouldn't it be more elegant to use accept_ra=2 as trigger instead of a new special
value for the forwarding option?

Best regards,
Daniel

-- 
CLUE-RIPE -- Jabber: dr@cluenet.de -- dr@IRCnet -- PGP: 0xA85C8AA0
