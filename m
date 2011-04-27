From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH rfc 1/5] r8169: style cleanups.
Date: Wed, 27 Apr 2011 14:00:43 -0700 (PDT)
Message-ID: <20110427.140043.183040785.davem@davemloft.net>
References: <20110427203654.GD19708@electric-eye.fr.zoreil.com>
	<1303937974.24299.92.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: romieu@fr.zoreil.com, netdev@vger.kernel.org, nic_swsd@realtek.com
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59722
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753215Ab1D0VBQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Apr 2011 17:01:16 -0400
In-Reply-To: <1303937974.24299.92.camel@Joe-Laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>
Date: Wed, 27 Apr 2011 13:59:34 -0700

> On Wed, 2011-04-27 at 22:36 +0200, Francois Romieu wrote:
>> Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
> []
>> diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
> []
>> @@ -3134,8 +3128,8 @@ static void r8168_pll_power_down(struct rtl8169_private *tp)
> []
>> -	if (tp->mac_version == RTL_GIGA_MAC_VER_32 ||
>> -	    tp->mac_version == RTL_GIGA_MAC_VER_33)
>> +	if ((tp->mac_version == RTL_GIGA_MAC_VER_32) ||
>> +	    (tp->mac_version == RTL_GIGA_MAC_VER_33))
> 
> Shrug.  I don't think this is better.

Yeah, same here.
