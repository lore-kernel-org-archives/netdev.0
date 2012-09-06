From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH v2] ethtool: don't overwrite useful bits in advertising
 bitfield
Date: Thu, 6 Sep 2012 20:05:48 +0100
Message-ID: <1346958348.2714.34.camel@bwh-desktop.uk.solarflarecom.com>
References: <1345807965-16236-1-git-send-email-johangu@axis.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Johan Gunnarsson <johan.gunnarsson@axis.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:55458 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751927Ab2IFTFx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Sep 2012 15:05:53 -0400
In-Reply-To: <1345807965-16236-1-git-send-email-johangu@axis.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-08-24 at 13:32 +0200, Johan Gunnarsson wrote:
> There are bits in this bitfield that we want to leave untouched (PAUSE
> and ASYM_PAUSE bits) when changing other bits (speed and duplex bits.)
> Previously, these were always overwritten to zero when running commands
> like "ethtool -s eth0 speed 10 duplex full autoneg off".
> 
> Signed-off-by: Johan Gunnarsson <johangu@axis.com>
[...]

Applied, thanks.  I made some minor fixes to spelling and formatting.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
