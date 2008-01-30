From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] [NET] cpmac: convert to new Fixed PHY infrastructure
Date: Wed, 30 Jan 2008 12:09:42 -0500
Message-ID: <47A0AF56.3060804@garzik.org>
References: <416B8C5D-109C-4C03-807D-7EBB0AA9C366@kernel.crashing.org> <20080121204953.GA11384@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Kumar Gala <galak@kernel.crashing.org>,
	linuxppc-dev list <linuxppc-dev@ozlabs.org>,
	netdev@vger.kernel.org, Eugene Konev <ejka@imfi.kspu.ru>
To: avorontsov@ru.mvista.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:50048 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756143AbYA3RJz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Jan 2008 12:09:55 -0500
In-Reply-To: <20080121204953.GA11384@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Anton Vorontsov wrote:
> On Mon, Jan 21, 2008 at 01:19:41PM -0600, Kumar Gala wrote:
>> Anton,
>>
>> it looks like the "TI AR7 CPMAC Ethernet support" uses FIXED_PHY and  
>> was selecting FIXED_MII_100_FDX which is gone.
>>
>> Can you look into this.  I get the following warning now:
>>
>> scripts/kconfig/conf -s arch/powerpc/Kconfig
>> drivers/net/Kconfig:1713:warning: 'select' used by config symbol  
>> 'CPMAC' refers to undefined symbol 'FIXED_MII_100_FDX'
> 
> Wow. I thought there were no Fixed PHY users. :-)
> 
> Jeff, as you've already Acked Fixed PHY rework to go through powerpc
> tree, would you please Ack this patch in addition? I hope cpmac
> maintainer will fix remaining issues as time goes by.
> 
> Thanks!
> 
> - - - -
> From: Anton Vorontsov <avorontsov@ru.mvista.com>
> Subject: [PATCH] [NET] cpmac: convert to new Fixed PHY infrastructure
> 
> This patch converts cpmac to the new Fixed PHY infrastructure, though it
> doesn't fix all the problems with that driver. I didn't even bother to
> test this patch to compile, because cpmac driver is broken in several ways:
> 
> 1. This driver won't compile by itself because lack of its header describing
>    platform data;
> 2. It assumes that fixed PHYs should be created by the ethernet driver.
>    It is wrong assumption: fixed PHYs creation is platform code authority,
>    driver must blindly accept bus_id and phy_id platform data variables
>    instead.
> 
> Also, it seem that that driver doesn't have actual in-tree users, so
> nothing to fix further.
> 
> The main purpose of that patch is to get rid of the following Kconfig
> warning:
> 
> scripts/kconfig/conf -s arch/powerpc/Kconfig
> drivers/net/Kconfig:1713:warning: 'select' used by config symbol
> 'CPMAC' refers to undefined symbol 'FIXED_MII_100_FDX'
> 
> Signed-off-by: Anton Vorontsov <avorontsov@ru.mvista.com>

ACK


