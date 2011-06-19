From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2] Allow NICs to pass Frame Checksum up the stack.
Date: Sun, 19 Jun 2011 16:20:15 -0700 (PDT)
Message-ID: <20110619.162015.1284402754081338255.davem@davemloft.net>
References: <1308339615-5866-1-git-send-email-greearb@candelatech.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: greearb@candelatech.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:60218 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754765Ab1FSXUS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Jun 2011 19:20:18 -0400
In-Reply-To: <1308339615-5866-1-git-send-email-greearb@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: greearb@candelatech.com
Date: Fri, 17 Jun 2011 12:40:13 -0700

> This series provides ethtool support to set and get the rx-checksum
> flag, and adds support to the e100 driver.

Please don't create entire new ethtool ops just to set what amounts
precisely to a boolean flag, that's what ETHTOOL_{S,G}FLAGS is for.

The fact that we've exhausted 32-bits of flags in netdev->features
is not an acceptable reason to avoid using those interfaces.
