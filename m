From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH ethtool 0/5] Fix and enhance command-line parsing
Date: Fri, 25 Jun 2010 15:43:47 +0100
Message-ID: <1277477027.2094.2.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: Jeff Garzik <jgarzik@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:11497 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755788Ab0FYOnu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jun 2010 10:43:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series fixes the initialisation of RX n-tuple specs, adds
general support for named flags, and then uses that for message types
and extended offload flags.

Ben.

Ben Hutchings (5):
  ethtool: Parse integers into variables of different sizes and byte
    orders
  ethtool: Mark show_usage() as noreturn
  ethtool: Add support for named flags
  ethtool: Implement named message type flags
  ethtool: Use named flag support to update extended offload flags

 ethtool-util.h |   29 ++++-
 ethtool.8      |   66 ++++++++-
 ethtool.c      |  440 +++++++++++++++++++++++++++++++++++--------------------
 3 files changed, 368 insertions(+), 167 deletions(-)

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

