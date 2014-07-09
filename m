From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [PATCH C 1/7] net: fec: better implementation of iMX6
	ERR006358 quirk
Date: Wed, 9 Jul 2014 10:33:09 +0100
Message-ID: <20140709093309.GM21766@n2100.arm.linux.org.uk>
References: <20140708120117.GJ21766@n2100.arm.linux.org.uk> <E1X4oCZ-0004Yk-1O@rmk-PC.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw-1.arm.linux.org.uk ([78.32.30.217]:59968 "EHLO
	pandora.arm.linux.org.uk" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753971AbaGIJdN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jul 2014 05:33:13 -0400
Content-Disposition: inline
In-Reply-To: <E1X4oCZ-0004Yk-1O@rmk-PC.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 09, 2014 at 10:30:11AM +0100, Russell King wrote:
> Using a (delayed) workqueue for ERR006358 is not correct - a work queue
> is a single-trigger device.  Once the work queue has been scheduled, it
> can't be re-scheduled until it has been run.  This can cause problems -
> with an appropriate packet timing, we can end up with packets queued,
> but not sent by the hardware, resulting in the transmit timeout firing.

Oops, please ignore this patch; re-sent in error.

-- 
FTTC broadband for 0.8mile line: now at 9.7Mbps down 460kbps up... slowly
improving, and getting towards what was expected from it.
