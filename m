From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: More vlan tests before registering
 netdevice
Date: Fri, 02 Jan 2015 15:56:21 -0500 (EST)
Message-ID: <20150102.155621.2190810414905057279.davem@davemloft.net>
References: <1420007736-30822-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Yuval.Mintz@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53054 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751972AbbABU4X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Jan 2015 15:56:23 -0500
In-Reply-To: <1420007736-30822-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Date: Wed, 31 Dec 2014 08:35:36 +0200

> When register_netdevice() is called, netdevice's vlan filtering feature
> and supplied callbacks are checked to see the vlan implementation is
> not buggy.
> This adds an additional test - see that the vlan_features were filled
> correctly, as the vlan devices inherits those as its own features;
> Incorrect values set there would later prevent the vlan interface from being
> registered itself [as it doesn't implement the filtering ndos].
> 
> Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
 ...
> Not sure why take such a defensive approach regarding this feature.
> Perhaps it would have been better to simply remove these checks altogether.

I guess this is fine as a defensive test, so I'll apply this.

But do you actually know of any devices which have violated this rule
either now or in the past?  I quickly tried to audit the entire tree
for this right now and found no problems.
