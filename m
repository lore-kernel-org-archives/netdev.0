From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 0/0] sky2: update for 2.6.24
Date: Wed, 29 Aug 2007 12:39:22 -0700
Message-ID: <20070829193922.078561651@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:38109 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755782AbXH2Tme (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Aug 2007 15:42:34 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This version includes some new features:
  * support for new FE+ chips (not tested)

  * use PCI functions.  The only reason the driver
    wasn't doing it was the advanced error bits weren't
    accessbile on busted AMD chipsets without MMCONFIG
    access.

  * use PCI error recovery functions to access those
    functions. If no mmconfig then driver has to ignore
    PCI Express errors.

  * provide receive skb timestamping in driver. This is
    a big win because it saves an expensive time of day
    access per packet.

Tested on most chips already.
It would be good to put these in -mm to catch any
early problems.

-- 
Stephen Hemminger <shemminger@linux-foundation.org>

