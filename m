From: Robert Stonehouse <rstonehouse@solarflare.com>
Subject: [PATCH]  New driver "sfc" for Solarstorm SFC4000 controller - 3nd
 try
Date: Fri, 21 Dec 2007 16:53:40 +0000
Message-ID: <476BEF94.4000801@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-net-drivers@solarflare.com, spope@solarflare.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nextweb.net ([216.237.6.30]:55172 "EHLO
	smtp.covadwireless.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751016AbXLUQxp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Dec 2007 11:53:45 -0500
Received: from mail.nextweb.net (mail.nextweb.net [216.237.6.33])
	by smtp.covadwireless.net (Spam Firewall) with ESMTP id 83D40144985
	for <netdev@vger.kernel.org>; Fri, 21 Dec 2007 08:53:43 -0800 (PST)
Received: from mail.nextweb.net (mail.nextweb.net [216.237.6.33]) by smtp.covadwireless.net with ESMTP id ULPUfDcrMKHTrPGC for <netdev@vger.kernel.org>; Fri, 21 Dec 2007 08:53:43 -0800 (PST)
Received: from unknown (HELO mail.solarflare.com) ([216.237.3.213])
          (envelope-sender <rstonehouse@solarflare.com>)
          by mail.nextweb.net (qmail-ldap-1.03) with SMTP
          for <netdev@vger.kernel.org>; 21 Dec 2007 16:53:43 -0000
Received: from OCEX01.SolarFlarecom.com (unknown [10.20.40.32])
	by mail.solarflare.com (Postfix) with ESMTP id 993924492C
	for <netdev@vger.kernel.org>; Fri, 21 Dec 2007 08:53:42 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a resubmission of a new driver for Solarflare network controllers.

The driver supports several types of PHY (10Gbase-T, XFP, CX4) on six
different 10G and 1G boards.

The previous thread was:
  [PATCH] [RFC] New driver "sfc" for Solarstorm SFC4000 controller
  http://marc.info/?l=linux-netdev&m=119757352830103&w=2

Thanks to the people who looked at the previous patches. We have addressed
the following from received comments after the 2nd submission:
  - Use kzalloc where appropriate
  - Remove deprecated fastcall attributes
  - Use kernel routines for hex dumps and MAC address printing
  - Changes to logging MACROs

The last two patches were marked with RFC but I now think that this driver
is ready (withstanding any further review comments) and I would like to ask
that this driver is considered for merging.


The patch (against net-2.6.25) is at:
     https://support.solarflare.com/netdev/3/net-2.6.25-sfc-2.2.0029.patch

The new files may also be downloaded as a tarball:
     https://support.solarflare.com/netdev/3/net-2.6.25-sfc-2.2.0029.tgz

And for verification there is:
     https://support.solarflare.com/netdev/3/MD5SUMS


Happy Christmas

-- 
Robert Stonehouse
