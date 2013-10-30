From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] route: Exporting ip6_route_add() so that Bluetooth
 6LoWPAN can use it
Date: Wed, 30 Oct 2013 13:05:30 -0400 (EDT)
Message-ID: <20131030.130530.189456202959728966.davem@davemloft.net>
References: <1383124637-15533-1-git-send-email-jukka.rissanen@linux.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jukka.rissanen@linux.intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59624 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751970Ab3J3RFg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Oct 2013 13:05:36 -0400
In-Reply-To: <1383124637-15533-1-git-send-email-jukka.rissanen@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jukka Rissanen <jukka.rissanen@linux.intel.com>
Date: Wed, 30 Oct 2013 11:17:17 +0200

> Signed-off-by: Jukka Rissanen <jukka.rissanen@linux.intel.com>

Sorry, no.

There is no reason that external subsystems need to add ipv6 routes
using direct calls to these functions.
