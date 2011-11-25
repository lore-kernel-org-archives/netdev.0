From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] natsemi: make cable length magic configurable
Date: Fri, 25 Nov 2011 01:37:13 -0500 (EST)
Message-ID: <20111125.013713.1783082973236989821.davem@davemloft.net>
References: <201111241443.59191.jdelvare@suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, thockin@hockin.org, okir@suse.de
To: jdelvare@suse.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:51275 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750750Ab1KYGhV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Nov 2011 01:37:21 -0500
In-Reply-To: <201111241443.59191.jdelvare@suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jean Delvare <jdelvare@suse.de>
Date: Thu, 24 Nov 2011 14:43:59 +0100

> We had a customer report concerning problems with a Natsemi DP83815-D
> and long cables. With 100m cables, the network would be essentially dead,
> not a single packet would get through either way. We had to apply the
> patch below to make it work.

Please do not add new private device driver module knobs.

Instead, add generic flags to the ethtool interface or similar to
control device behavior.
