From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 3/3] x25: Move to staging
Date: Mon, 22 Nov 2010 20:31:55 -0800
Message-ID: <20101122203155.27534f3b@nehalam>
References: <1290484528.6770.1336.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Andrew Hendry <andrew.hendry@gmail.com>,
	David Miller <davem@davemloft.net>,
	Greg Kroah-Hartman <gregkh@suse.de>,
	netdev <netdev@vger.kernel.org>, devel@driverdev.osuosl.org,
	Debian kernel maintainers <debian-kernel@lists.debian.org>,
	linux-x25@vger.kernel.org
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:56396 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751691Ab0KWEb6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Nov 2010 23:31:58 -0500
In-Reply-To: <1290484528.6770.1336.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 23 Nov 2010 03:55:28 +0000
Ben Hutchings <ben@decadent.org.uk> wrote:

> Recent review has revealed several bugs in obscure protocol
> implementations that can be exploited by local users for denial of
> service or privilege escalation.
> 
> The x25 protocol (PF_X25) receives only 'odd fixes'.  There appear to
> be no published applications for it, and it has never progressed
> beyond 'experimental' status.
> 
> This protocol generally should not be enabled by distributions, since
> the cost of a security flaw affecting all installed systems presumably
> outweighs the benefit to the few (if any) legitimate users.
> 
> Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
> ---
> I'm somewhat less sure about this one; maybe it's improving?  But there
> is little enough sign of any usefulness after 10 years.
> 
> There are several X25 dependencies that presumably should be moved too.

No. If you don't like it then don't enable it.
