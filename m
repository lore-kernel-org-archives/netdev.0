From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: [PATCH] EtherIP tunnel driver (RFC 3378)
Date: Mon, 18 Sep 2006 22:52:52 +0200
Message-ID: <20060918205252.GA6830@xi.wantstofly.org>
References: <20060911204129.GA28929@zlug.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from alephnull.demon.nl ([83.160.184.112]:3753 "EHLO
	xi.wantstofly.org") by vger.kernel.org with ESMTP id S964983AbWIRUw4
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Sep 2006 16:52:56 -0400
To: Joerg Roedel <joro-lkml@zlug.org>
Content-Disposition: inline
In-Reply-To: <20060911204129.GA28929@zlug.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Sep 11, 2006 at 10:41:29PM +0200, Joerg Roedel wrote:

> This driver implements the tunneling of Ethernet packets over IPv4
> networks for Linux. It uses the protocol defined in RFC 3378.

Check out the thread "[PATCH][RFC] etherip: Ethernet-in-IPv4 tunneling"
that was on netdev in January of 2005 -- a number of arguments against
etherip (and for tunneling ethernet in GRE) were raised back then.

One of the most significant ones, IMHO:

> Another argument against etherip would be that OpenBSD apparently
> mis-implemented etherip by putting the etherip version nibble in the
> second nibble of the etherip header instead of the first, which would
> probably prevent the linux and OpenBSD versions from interoperating,
> negating the advantage of using etherip in the first place.


cheers,
Lennert
