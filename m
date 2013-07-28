From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bonding: remove
 bond_resend_igmp_join_requests read_unlock leftover
Date: Sun, 28 Jul 2013 01:08:23 -0700 (PDT)
Message-ID: <20130728.010823.102546255255486705.davem@davemloft.net>
References: <1374945010-14667-1-git-send-email-nikolay@redhat.com>
	<20130727200754.GA2395@minipsycho.orion>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nikolay@redhat.com, netdev@vger.kernel.org, andy@greyhouse.net,
	fubar@us.ibm.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54608 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751266Ab3G1II1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Jul 2013 04:08:27 -0400
In-Reply-To: <20130727200754.GA2395@minipsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Sat, 27 Jul 2013 22:07:54 +0200

> Sat, Jul 27, 2013 at 07:10:10PM CEST, nikolay@redhat.com wrote:
>>After commit 4aa5dee4d9 ("net: convert resend IGMP to notifier event") we
>>have 1 read_unlock in bond_resend_igmp_join_requests which isn't paired
>>with a read_lock because it's removed by that commit.
> 
> Oups
> 
>>
>>Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
> Reviewed-by: Jiri Pirko <jiri@resnulli.us>

Applied, thanks.
