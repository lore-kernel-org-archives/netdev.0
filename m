From: Robert Stonehouse <rstonehouse@solarflare.com>
Subject: [PATCH] [RFC] New driver "sfc" for Solarstorm SFC4000 controller
 - 2nd try
Date: Thu, 13 Dec 2007 19:18:38 +0000
Message-ID: <4761858E.2040709@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-net-drivers@solarflare.com, spope@solarflare.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.nextweb.net ([216.237.6.33]:4167 "EHLO mail.nextweb.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754298AbXLMTSm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Dec 2007 14:18:42 -0500
Received: from unknown (HELO mail.solarflare.com) ([216.237.3.213])
          (envelope-sender <rstonehouse@solarflare.com>)
          by mail.nextweb.net (qmail-ldap-1.03) with SMTP
          for <netdev@vger.kernel.org>; 13 Dec 2007 19:18:40 -0000
Received: from OCEX01.SolarFlarecom.com (unknown [10.20.40.32])
	by mail.solarflare.com (Postfix) with ESMTP id 511CA4492E
	for <netdev@vger.kernel.org>; Thu, 13 Dec 2007 11:18:40 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a resubmission of a new driver for Solarflare network controllers.

The driver supports many types of PHY (10Gbase-T, XFP, CX4) on five
different 10G reference designs and one 1G NIC ref design.

The previous thread was:
  "[PATCH] [RFC] New driver "sfc" for Solarstorm SFC4000 controller"
  http://marc.info/?l=linux-netdev&m=119583775622559&w=2


Since the 1st patch we have addressed the review comments we received
 - removed usage of __LINK_STATE_START as unnecessary with latest NAPI
 - cleaned up many checkpatch violations
 - used the generic drv_* logging
   (macros were kept so that the network device name can be printed
consistently in all messaging but these can be dissolved if necessary)
 - Reduced over-use of docbook type comments
 - replaced uintN_t with uN types
 - merged some small headers to reduce the file count

It is still quite a large driver at ~25k LOC. The main body of the driver
is within efx.c, falcon.c, tx.c and rx.c if this helps direct review effort.

We welcome more review comments and will try and respond to them more
quickly than last time.

The patch (against net-2.6.25) is at:
    https://support.solarflare.com/netdev/2/net-2.6.25-sfc-2.2.0026.patch

The new files may also be downloaded as a tarball:
    https://support.solarflare.com/netdev/2/net-2.6.25-sfc-2.2.0026.tgz

And for verification there is:
    https://support.solarflare.com/netdev/2/MD5SUMS


Regards

-- 
Rob Stonehouse
