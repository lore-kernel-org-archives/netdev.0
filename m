From: David Miller <davem@davemloft.net>
Subject: Re: [RFC V4 PATCH] rtnetlink: Compute and store minimum ifinfo
 dump size
Date: Wed, 18 May 2011 18:47:41 -0400 (EDT)
Message-ID: <20110518.184741.476096648010572360.davem@davemloft.net>
References: <20110518155410.28491.62723.stgit@gitlad.jf.intel.com>
	<20110518.180913.273729651812642114.davem@davemloft.net>
	<43F901BD926A4E43B106BF17856F0755018E321C21@orsmsx508.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bhutchings@solarflare.com,
	eric.dumazet@gmail.com
To: gregory.v.rose@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:42553 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754373Ab1ERWrw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 May 2011 18:47:52 -0400
In-Reply-To: <43F901BD926A4E43B106BF17856F0755018E321C21@orsmsx508.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Rose, Gregory V" <gregory.v.rose@intel.com>
Date: Wed, 18 May 2011 15:35:58 -0700

> It looked to me like rtmsg_ifinfo is called when each device is
> registered through register_netdevice() and rtmsg_ifinfo in turn
> calls the if_nlmsg_size function returning the ifinfo dump size for
> each device.  In my testing it looked like the proper maximum size
> was being set after I loaded the drivers for the SR-IOV capable
> devices.

Aha, indeed you're right.  I missed this part.  Thanks for explaining.

So as far as I can tell it should work, I'll let others review it to
see if they are ok with this approach.

Thanks.
