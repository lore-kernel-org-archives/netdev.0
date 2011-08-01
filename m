From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6 1/2] be2net: cleanup and refactor stats
 code
Date: Mon, 01 Aug 2011 01:54:58 -0700 (PDT)
Message-ID: <20110801.015458.572481070444067078.davem@davemloft.net>
References: <1311657015-23465-1-git-send-email-sathya.perla@emulex.com>
	<1311657015-23465-2-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sathya.perla@emulex.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:39644 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750699Ab1HAIzD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Aug 2011 04:55:03 -0400
In-Reply-To: <1311657015-23465-2-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sathya Perla <sathya.perla@emulex.com>
Date: Tue, 26 Jul 2011 10:40:14 +0530

> In preparation for 64-bit stats interface, the following cleanups help
> streamline the code:
> 1) made some more rx/tx stats stored by driver 64 bit
> 2) made some HW stas (err/drop counters) stored in be_drv_stats 32 bit to
>    keep the code simple as BE provides 32-bit counters only.
> 3) removed duplication of netdev stats in ethtool
> 4) removed some un-necessary stats and fixed some names
> 
> Signed-off-by: Sathya Perla <sathya.perla@emulex.com>

Queued up for net-next
