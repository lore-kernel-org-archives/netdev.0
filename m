From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 0/8] New driver "sfc" for Solarstorm SFC4000 controller (try #8)
Date: Wed, 12 Mar 2008 01:21:03 +0000
Message-ID: <20080312012102.GB24160@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-net-drivers@solarflare.com, Jeff Garzik <jgarzik@pobox.com>,
	David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 82-69-137-158.dsl.in-addr.zen.co.uk ([82.69.137.158]:54836 "EHLO
	uklogin.uk.level5networks.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752142AbYCLCWu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Mar 2008 22:22:50 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a resubmission of a new driver for Solarflare network controllers.

The driver supports the 10Xpress PHY and XFP modules on our reference
designs SFE4001 and SFE4002 and the SMC models SMC10GPCIe-XFP and
SMC10GPCIe-10BT.

The previous thread was:
  http://marc.info/?t=120162624600002&r=1&w=2

Some explanation of the driver structure was posted in:
  http://marc.info/?l=linux-netdev&m=119999015817920&w=2

Since the last patch we have made a few bug fixes and removed some
less important features and hardware support, reducing it to 13K
lines.

We would appreciate a thorough review.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
