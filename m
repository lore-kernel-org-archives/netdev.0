From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next 6/6] be2net: fix to set ecmd->autoneg correctly
Date: Fri, 05 Aug 2011 22:51:59 +0100
Message-ID: <1312581119.2715.49.camel@bwh-desktop>
References: <20110805200107.GA13631@akhaparde-VBox>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Ajit Khaparde <ajit.khaparde@emulex.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:36615 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752299Ab1HEVwB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Aug 2011 17:52:01 -0400
In-Reply-To: <20110805200107.GA13631@akhaparde-VBox>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2011-08-05 at 15:01 -0500, Ajit Khaparde wrote:
> Set the autonegotation settings correctly based on the port speed.
[...]

Autonegotiation and multi-speed are two entirely different things.

Selecting a single speed doesn't mean turning autoneg off.  If you
enable only 1000BASE-T or only 10GBASE-T, the PHY must still go through
autoneg to determine whether it is the clock master for the link.

Enabling multiple speeds doesn't mean turning autoneg on.  An SFP+ slot
can take 1G and 10G modules but the modules generally won't support
autoneg.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

