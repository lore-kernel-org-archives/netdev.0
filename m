From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3] net: Do not call ndo_dflt_fdb_dump if
 ndo_fdb_dump is defined
Date: Sat, 20 Dec 2014 15:05:54 -0500 (EST)
Message-ID: <20141220.150554.88974537269596572.davem@davemloft.net>
References: <54941689.7060100@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ray.kinsella@intel.com
To: hubert.sokolowski@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42671 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751104AbaLTUGA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Dec 2014 15:06:00 -0500
In-Reply-To: <54941689.7060100@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hubert Sokolowski <hubert.sokolowski@intel.com>
Date: Fri, 19 Dec 2014 12:14:01 +0000

> At the same time it is desirable to call the default dump
> function on a bridge device.

Device specific things do not belong in generic code.

If the bridging device wants specific behavior wrt. this
callback, it can implement the callback as needed.
