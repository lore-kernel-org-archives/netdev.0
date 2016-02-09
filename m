From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bonding: 3ad: apply ad_actor settings changes
 immediately
Date: Tue, 09 Feb 2016 04:46:23 -0500 (EST)
Message-ID: <20160209.044623.363701419884066716.davem@davemloft.net>
References: <1454501821-22175-1-git-send-email-razor@blackwall.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nikolay@cumulusnetworks.com,
	j.vosburgh@gmail.com, vfalico@gmail.com, gospo@cumulusnetworks.com
To: razor@blackwall.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53832 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756295AbcBIJq3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Feb 2016 04:46:29 -0500
In-Reply-To: <1454501821-22175-1-git-send-email-razor@blackwall.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <razor@blackwall.org>
Date: Wed,  3 Feb 2016 13:17:01 +0100

> From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
> 
> Currently the bonding allows to set ad_actor_system and prio while the
> bond device is down, but these are actually applied only if there aren't
> any slaves yet (applied to bond device when first slave shows up, and to
> slaves at 3ad bind time). After this patch changes are applied immediately
> and the new values can be used/seen after the bond's upped so it's not
> necessary anymore to release all and enslave again to see the changes.
> 
> CC: Jay Vosburgh <j.vosburgh@gmail.com>
> CC: Veaceslav Falico <vfalico@gmail.com>
> CC: Andy Gospodarek <gospo@cumulusnetworks.com>
> Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

Applied, thanks Nikolay.
