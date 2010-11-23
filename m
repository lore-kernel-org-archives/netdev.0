From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 1/3] decnet: Move to staging
Date: Mon, 22 Nov 2010 20:31:31 -0800
Message-ID: <20101122203131.7cbd604b@nehalam>
References: <1290484313.6770.1328.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Greg Kroah-Hartman <gregkh@suse.de>,
	netdev <netdev@vger.kernel.org>, devel@driverdev.osuosl.org,
	Debian kernel maintainers <debian-kernel@lists.debian.org>
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:56370 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751017Ab0KWEbe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Nov 2010 23:31:34 -0500
In-Reply-To: <1290484313.6770.1328.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 23 Nov 2010 03:51:53 +0000
Ben Hutchings <ben@decadent.org.uk> wrote:

> Recent review has revealed several bugs in obscure protocol
> implementations that can be exploited by local users for denial of
> service or privilege escalation.
> 
> The decnet protocol (PF_DECnet) is unmaintained.  Since 2.6.12-rc2 the
> only changes appear to be adjustments for net API changes and fixes
> for bugs found by inspection.
> 
> This protocol generally should not be enabled by distributions, since
> the cost of a security flaw affecting all installed systems presumably
> outweighs the benefit to the few (if any) legitimate users.
> 
> Signed-off-by: Ben Hutchings <ben@decadent.org.uk>

NAK there are still users and stuff does get fixed.
If you don't like it then disable it from config.



-- 
