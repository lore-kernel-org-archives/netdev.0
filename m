From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 2/3] econet: Move to staging
Date: Mon, 22 Nov 2010 20:32:36 -0800
Message-ID: <20101122203236.029c86e3@nehalam>
References: <1290484348.6770.1329.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Greg Kroah-Hartman <gregkh@suse.de>,
	netdev <netdev@vger.kernel.org>, devel@driverdev.osuosl.org,
	Debian kernel maintainers <debian-kernel@lists.debian.org>
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:56420 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751750Ab0KWEci (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Nov 2010 23:32:38 -0500
In-Reply-To: <1290484348.6770.1329.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 23 Nov 2010 03:52:28 +0000
Ben Hutchings <ben@decadent.org.uk> wrote:

> Recent review has revealed several bugs in obscure protocol
> implementations that can be exploited by local users for denial of
> service or privilege escalation.
> 
> The econet protocol (PF_ECONET) is unmaintained.  There appear to be
> no published applications for it, and it has never progressed beyond
> 'experimental' status.
> 
> This protocol generally should not be enabled by distributions, since
> the cost of a security flaw affecting all installed systems presumably
> outweighs the benefit to the few (if any) legitimate users.
> 
> Signed-off-by: Ben Hutchings <ben@decadent.org.uk>

This I agree with. Probably the Arcnet devices as well.
Most distro's don't enable it anyway.
