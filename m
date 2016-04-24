From: David Miller <davem@davemloft.net>
Subject: Re: [patch net 0/3] bridge: mdb: Couple of fixes
Date: Sun, 24 Apr 2016 14:23:59 -0400 (EDT)
Message-ID: <20160424.142359.2144390135732997955.davem@davemloft.net>
References: <1461235965-3930-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com,
	stephen@networkplumber.org, nikolay@cumulusnetworks.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52508 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752010AbcDXSYE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Apr 2016 14:24:04 -0400
In-Reply-To: <1461235965-3930-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Thu, 21 Apr 2016 12:52:42 +0200

> From: Jiri Pirko <jiri@mellanox.com>
> 
> Elad says:
> 
> This patchset fixes two problems reported by Nikolay Aleksandrov. The first
> problem is that the MDB offload flag might be accesed without helding the
> multicast_lock.
> The second problem is that the switchdev mdb offload is deferred and
> the offload bit was marked regardless if the operation succeeded or not.

Series applied, thanks.
