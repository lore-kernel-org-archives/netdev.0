From: Ursula Braun <braunu@de.ibm.com>
Subject: [patch 0/3] s390: ctc patches for 2.6.25 (4th try)
Date: Fri, 08 Feb 2008 00:03:47 +0100
Message-ID: <20080207230347.075759000@linux.vnet.ibm.com>
To: jgarzik@pobox.com, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate6.de.ibm.com ([195.212.29.155]:24523 "EHLO
	mtagate6.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759691AbYBGX0I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Feb 2008 18:26:08 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

-- 
Jeff,

this resend includes improvements proposed by Christoph Hellwig:
  netiucv changes are postponed to a future patch
  drivers/s390/net/fsm.h is not changed
  drivers/s390/net/Makefile is adapted
  changed indentation of cpp directives
  removed forward declaration of chx_rxidle
  removed kerneldoc-like keywords
  removed unnecessary type casts
  kept local variable of type struct ctcm_priv

We kept the filenames in the top of file comments, since this is common
to drivers/s390-parts.
And we kept the ccw_device_halt call due to different usages
in different drivers.

The following patches are intended for 2.6.25. Besides clean-ups
they replace the old ctc driver by a reworked ctcm driver.
This ctcm driver supports the channel-to-channel connections of the
old ctc driver plus an additional MPC protocol to provide SNA
connectivity.

Patch 1/3: clean-ups in Kconfig
Patch 2/3: reworked ctc driver
Patch 3/3: removal of old ctc driver

Regards,    Ursula Braun
