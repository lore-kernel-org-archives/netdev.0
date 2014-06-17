From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [PATCH] net: fec: remove HW IP header checksum for IPV6 frame
Date: Wed, 18 Jun 2014 00:21:51 +0100
Message-ID: <20140617232151.GO23430@n2100.arm.linux.org.uk>
References: <1402993895-10955-1-git-send-email-b38611@freescale.com> <20140617163121.GM23430@n2100.arm.linux.org.uk> <20140617.153407.622542669190595342.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: b38611@freescale.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw-1.arm.linux.org.uk ([78.32.30.217]:33377 "EHLO
	pandora.arm.linux.org.uk" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752521AbaFQXV5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jun 2014 19:21:57 -0400
Content-Disposition: inline
In-Reply-To: <20140617.153407.622542669190595342.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 17, 2014 at 03:34:07PM -0700, David Miller wrote:
> From: Russell King - ARM Linux <linux@arm.linux.org.uk>
> Date: Tue, 17 Jun 2014 17:31:21 +0100
> > As I suspected, just applying the above two hunks fixes the problem
> > I was seeing.
> 
> Someone please respin the patch so that it's just these two hunks and that
> the commit message accurately describes the real situation.

I'm hoping for a reply from Freescale before I give an explicit tested-by
against this.  It would be nice to have some explicit confirmation that
they would be happy with a reduced patch.  It may be that the hardware
really does need the IP header checksum bit cleared for non-IPv4
packets.

-- 
FTTC broadband for 0.8mile line: now at 9.7Mbps down 460kbps up... slowly
improving, and getting towards what was expected from it.
