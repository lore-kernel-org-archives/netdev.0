From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] net: phy: at803x: add suspend/resume callbacks
Date: Fri, 27 Sep 2013 17:28:47 -0400 (EDT)
Message-ID: <20130927.172847.499277297343578722.davem@davemloft.net>
References: <1379775182-1271-2-git-send-email-zonque@gmail.com>
	<523E877F.4050906@ti.com>
	<5245D31C.4080104@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mugunthanvnm@ti.com, netdev@vger.kernel.org, ujhelyi.m@gmail.com,
	sergei.shtylyov@cogentembedded.com
To: zonque@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50750 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753639Ab3I0V2t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Sep 2013 17:28:49 -0400
In-Reply-To: <5245D31C.4080104@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Mack <zonque@gmail.com>
Date: Fri, 27 Sep 2013 20:49:00 +0200

> On 22.09.2013 08:00, Mugunthan V N wrote:
>> On Saturday 21 September 2013 08:23 PM, Daniel Mack wrote:
>>> When WOL is enabled, the chip can't be put into power-down (BMCR_PDOWN)
>>> mode, as that will also switch off the MAC, which consequently leads to
>>> a link loss.
>>>
>>> Use BMCR_ISOLATE in that case, which will at least save us some
>>> milliamperes in comparison to normal operation mode.
>>>
>>> Signed-off-by: Daniel Mack <zonque@gmail.com>
>> Looks good to me
>> 
>> Acked-by: Mugunthan V N <mugunthanvnm@ti.com>
> 
> Thanks :)
> 
> David, can you take these two patches with Mugunthan's Acked-by: or do
> you want me to resend them?

Both applied to net-next, thanks.
