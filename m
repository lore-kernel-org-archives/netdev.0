From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2] xen/netback: Properly initialize credit_bytes
Date: Wed, 27 May 2015 12:57:10 -0400 (EDT)
Message-ID: <20150527.125710.930095988390854814.davem@davemloft.net>
References: <1432723472-7793-1-git-send-email-ross.lagerwall@citrix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xen-devel@lists.xenproject.org,
	wei.liu2@citrix.com, ian.campbell@citrix.com
To: ross.lagerwall@citrix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37253 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751358AbbE0RAS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 May 2015 13:00:18 -0400
In-Reply-To: <1432723472-7793-1-git-send-email-ross.lagerwall@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ross Lagerwall <ross.lagerwall@citrix.com>
Date: Wed, 27 May 2015 11:44:32 +0100

> Commit e9ce7cb6b107 ("xen-netback: Factor queue-specific data into queue
> struct") introduced a regression when moving queue-specific data into
> the queue struct by failing to set the credit_bytes field. This
> prevented bandwidth limiting from working. Initialize the field as it
> was done before multiqueue support was added.
> 
> Signed-off-by: Ross Lagerwall <ross.lagerwall@citrix.com>

Applied, thanks Ross.
