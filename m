From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] natsemi: make cable length magic configurable
Date: Mon, 28 Nov 2011 16:45:13 -0500 (EST)
Message-ID: <20111128.164513.899219888557202127.davem@davemloft.net>
References: <201111241443.59191.jdelvare@suse.de>
	<20111125.013713.1783082973236989821.davem@davemloft.net>
	<1322502664.26733.9.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jdelvare@suse.de, netdev@vger.kernel.org, thockin@hockin.org,
	okir@suse.de
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:58996 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752455Ab1K1Vp1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2011 16:45:27 -0500
In-Reply-To: <1322502664.26733.9.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Mon, 28 Nov 2011 17:51:04 +0000

> On Fri, 2011-11-25 at 01:37 -0500, David Miller wrote:
>> From: Jean Delvare <jdelvare@suse.de>
>> Date: Thu, 24 Nov 2011 14:43:59 +0100
>> 
>> > We had a customer report concerning problems with a Natsemi DP83815-D
>> > and long cables. With 100m cables, the network would be essentially dead,
>> > not a single packet would get through either way. We had to apply the
>> > patch below to make it work.
>> 
>> Please do not add new private device driver module knobs.
>> 
>> Instead, add generic flags to the ethtool interface or similar to
>> control device behavior.
> 
> This isn't a generic flag; it seems to be a workaround for a specific
> bug that unfortunately can't be automatic.
> 
> That's why I suggested an ethtool private flag.

Fair enough.
