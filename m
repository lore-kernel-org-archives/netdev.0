From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ezchip: adapt driver to little endian architecture
Date: Fri, 26 Feb 2016 15:25:19 -0500 (EST)
Message-ID: <20160226.152519.25582868690139177.davem@davemloft.net>
References: <1456513509-30844-1-git-send-email-ltrimas@synopsys.com>
	<24793363.yg41IbJKTo@wuerfel>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Lada.Trimasova@synopsys.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Alexey.Brodkin@synopsys.com,
	noamc@ezchip.com, talz@ezchip.com
To: arnd@arndb.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33240 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754786AbcBZUZV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Feb 2016 15:25:21 -0500
In-Reply-To: <24793363.yg41IbJKTo@wuerfel>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arnd Bergmann <arnd@arndb.de>
Date: Fri, 26 Feb 2016 21:10:31 +0100

> On Friday 26 February 2016 22:05:09 Lada Trimasova wrote:
>>                 for (i = 0; i < len; i++, reg++) {
>>                         u32 buf = nps_enet_reg_get(priv, NPS_ENET_REG_RX_BUF);
>> +                       buf = be32_to_cpu(buf);
>>                         put_unaligned(buf, reg);
>>                 }
> 
> I think most of the changes can make use of the put_unaligned_be32()
> etc helpers that might also be more efficient.

Agreed.
