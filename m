From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/2] be2net: fix ethtool ringparam reporting
Date: Tue, 13 Dec 2011 13:34:44 -0500 (EST)
Message-ID: <20111213.133444.1070704928888560046.davem@davemloft.net>
References: <1323773930-6617-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sathya.perla@emulex.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:49631 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753077Ab1LMSes (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Dec 2011 13:34:48 -0500
In-Reply-To: <1323773930-6617-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sathya Perla <sathya.perla@emulex.com>
Date: Tue, 13 Dec 2011 16:28:49 +0530

> The ethtool "-g" option is supposed to report the max queue length and
> user modified queue length for RX and TX queues.  be2net doesn't support
> user modification of queue lengths. So, the correct values for these
> would be the max numbers.
> be2net incorrectly reports the queue used values for these fields.
> 
> Signed-off-by: Sathya Perla <sathya.perla@emulex.com>

Applied.
