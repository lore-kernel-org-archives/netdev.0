From: <Somnath.Kotur@Emulex.Com>
Subject: RE: [PATCH net-next v4] be2net: Fix to allow get/set of debug
 levels in the firmware.
Date: Thu, 17 May 2012 18:47:50 -0700
Message-ID: <80fb6a42-aa9a-4288-aa96-c6aa5972bc03@exht1.ad.emulex.com>
References: <23cb36ad-2827-44bd-a91a-c6d8b01db70e@exht1.ad.emulex.com>
 <20120517.162116.881586126577077171.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>, <bhutchings@solarflare.com>,
	<Suresh.Reddy@emulex.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:49195 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1762182Ab2ERBsQ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 May 2012 21:48:16 -0400
In-Reply-To: <20120517.162116.881586126577077171.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

> 
> This doesn't apply cleanly to net-next, please respin.
>
OK, need to figure out how did that happen and will respin

> Also, you should convert your driver now to use ->msg_enable to gate all of
> your driver's kernel message logging, not just this firmware stuff.

At the moment our driver does not have any extensive logging facility, but yes
going forward we will use this infrastructure to gate all our driver's logging and will send
separate patch(es) for that in future.

Does that sound good for now?  A respin for this current patch 

Thanks
Som
