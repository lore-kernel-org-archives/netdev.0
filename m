From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bnx2x: remove dead code and make local funcs static
Date: Sun, 24 Feb 2013 20:16:29 -0500 (EST)
Message-ID: <20130224.201629.1227238267432882976.davem@davemloft.net>
References: <20130222100110.057520e1@nehalam.linuxnetplumber.net>
	<1361737520.3557.3.camel@lb-tlvb-eilong.il.broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, netdev@vger.kernel.org,
	dmitry@broadcom.com, yanivr@broadcom.com
To: eilong@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43922 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759537Ab3BYBQb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Feb 2013 20:16:31 -0500
In-Reply-To: <1361737520.3557.3.camel@lb-tlvb-eilong.il.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Eilon Greenstein" <eilong@broadcom.com>
Date: Sun, 24 Feb 2013 22:25:20 +0200

> On Fri, 2013-02-22 at 10:01 -0800, Stephen Hemminger wrote:
>> Sparse warned about several functions that were unnecessarily global.
>> After making them static, discovered that several functions were actually never used.
>> 
>> Compile tested only.
>> 
>> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
>> 
> 
> Hi Stephen,
> 
> Thanks for this patch. The "dead code" part is actually a missing call
> in case of PHY FW upgrade for the 84833 PHY - without it, a server
> reboot is required for the new PHY FW to take affect - but this reboot
> saving enhancement should wait until net-next is open, so I'm acking
> this patch and we will add the code back with the proper call once the
> net-next is open again.
> 
> Acked-by: Eilon Greenstein <eilong@broadcomo.com>

Applied.
