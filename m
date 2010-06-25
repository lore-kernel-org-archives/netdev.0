From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next-2.6 0/4] More sfc changes for 2.6.36
Date: Fri, 25 Jun 2010 18:03:54 +0100
Message-ID: <1277485434.2094.13.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:20147 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756529Ab0FYREB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jun 2010 13:04:01 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave,

You appear to have applied all my previous patches to net-next-2.6, so
here are the fix-ups for hash insertion.  Also, an improvement in
hardware monitoring which has been in the the out-of-tree sfc driver for
a while but which I failed to carry over.

Ben.

Ben Hutchings (4):
  sfc: Fix reading of inserted hash
  sfc: Move siena_nic_data::ipv6_rss_key to efx_nic::rx_hash_key
  sfc: Use Toeplitz IPv4 hash for RSS and hash insertion
  sfc: Log clearer error messages for hardware monitor

 drivers/net/sfc/efx.c           |    3 +++
 drivers/net/sfc/falcon.c        |   14 ++++++++++++--
 drivers/net/sfc/falcon_boards.c |   11 ++++++++---
 drivers/net/sfc/net_driver.h    |    1 +
 drivers/net/sfc/nic.h           |    1 -
 drivers/net/sfc/rx.c            |   11 ++++++-----
 drivers/net/sfc/selftest.c      |    3 ---
 drivers/net/sfc/siena.c         |   23 ++++++++++++++---------
 8 files changed, 44 insertions(+), 23 deletions(-)

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

