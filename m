From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH ethtool 0/7] Update RX n-tuple filtering
Date: Thu, 23 Sep 2010 22:47:08 +0100
Message-ID: <1285278428.7794.27.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:54452 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754897Ab0IWVrL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Sep 2010 17:47:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series brings ethtool up to date with my recent changes to RX
n-tuple filtering in the kernel.

Ben.

Ben Hutchings (7):
  ethtool-copy.h: sync with net-next
  ethtool: Generalise cmdline_info::unwanted_val to a "seen" flag or
    bitmask
  ethtool: Fix RX n-tuple masks and documentation
  ethtool: Add MAC parameter type based on the parse_sopass() function
  ethtool: Add Ethernet-level RX n-tuple filtering and 'clear' action
  ethtool: Update sfc register dump
  ethtool: Add my authorship and Solarflare copyright notice

 AUTHORS        |    1 +
 ethtool-copy.h |  228 +++++++++++++++++++++++++++++++++---------------
 ethtool.8      |   79 ++++++++++++-----
 ethtool.c      |  265 +++++++++++++++++++++++++++++++++++++++++---------------
 sfc.c          |   25 +++---
 5 files changed, 426 insertions(+), 172 deletions(-)

-- 
1.7.2.1


-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

