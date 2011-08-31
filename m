From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] ethtool: Uncook tg3 regdump output
Date: Wed, 31 Aug 2011 23:25:30 +0100
Message-ID: <1314829530.3274.42.camel@bwh-desktop>
References: <1314842557-32247-1-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Matt Carlson <mcarlson@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:12428 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756714Ab1HaWZd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Aug 2011 18:25:33 -0400
In-Reply-To: <1314842557-32247-1-git-send-email-mcarlson@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2011-08-31 at 19:02 -0700, Matt Carlson wrote:
> tg3 devices have changed a lot since the bcm5700 days.  Register blocks
> have been added, removed and redefined.  The existing tg3 register dump
> code has not kept up.
> 
> This patch changes the tg3_dump_regs() function to be more simplistic.
> Rather than attempting to locate where meaningful data is, it will
> instead print the registers as 32-bit values, omitting all registers
> that have a value of zero.  By performing the output this way, we hope
> to future-proof the interface.
[...]

Applied.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
