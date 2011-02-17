From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: Question about tg3 and bnx2 driver suppliers
Date: Thu, 17 Feb 2011 14:16:32 +0000
Message-ID: <1297952192.2637.7.camel@bwh-desktop>
References: <3BA51C2C-B28F-4FED-BF5D-B9BF46EAF3F7@highwire.stanford.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Michael Durket <durket@highwire.stanford.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:59804 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751728Ab1BQOQf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Feb 2011 09:16:35 -0500
In-Reply-To: <3BA51C2C-B28F-4FED-BF5D-B9BF46EAF3F7@highwire.stanford.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2011-02-17 at 05:24 -0800, Michael Durket wrote:
> I'm trying to fix a problem with packet drops and frame errors (really
> rxbds_empty and rx_discards (or rx_fw_discards depending on whether or
> not its a tg3 supported chip or a bnx2 chip)). We have this happening
> on pretty much all the RedHat 5.x systems we're running these drivers
> on. In investigating what remedies to employ to fix this, I'm trying
> to determine if new versions of this driver are supplied by Broadcom,
> or by people within the Linux community so 
> I can find the right place to ask questions about it. I'm pretty sure
> this isn't the right list for these types of questions, but if someone
> could tell me whether I should be contacting Broadcom directly, or the
> name of some other Linux mailing list or forum that might help, I'd
> appreciate it.

If you received the drivers as part of RHEL, you should ask Red Hat.
However, in general, RH takes drivers from Linus's tree - either as part
of a complete release, or as a backport.  Most development on network
drivers for current production seems to be done by developers employed
or contracted by the corresponding manufacturers, but it is subject to
review by the Linux community as represented here on netdev.

The MAINTAINERS file in the Linux source tree lists the primary
maintainer(s) for each driver:

BROADCOM BNX2 GIGABIT ETHERNET DRIVER
M:	Michael Chan <mchan@broadcom.com>
L:	netdev@vger.kernel.org
S:	Supported
F:	drivers/net/bnx2.*
F:	drivers/net/bnx2_*

BROADCOM TG3 GIGABIT ETHERNET DRIVER
M:	Matt Carlson <mcarlson@broadcom.com>
M:	Michael Chan <mchan@broadcom.com>
L:	netdev@vger.kernel.org
S:	Supported
F:	drivers/net/tg3.*

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

