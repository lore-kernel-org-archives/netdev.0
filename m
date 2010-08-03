From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ip_fragment: fix subtracting PPPOE_SES_HLEN from mtu
 twice
Date: Mon, 02 Aug 2010 17:25:21 -0700 (PDT)
Message-ID: <20100802.172521.71579154.davem@davemloft.net>
References: <1280618708-9241-1-git-send-email-xiaosuo@gmail.com>
	<4C56E961.9070107@trash.net>
	<4C571A70.20103@pandora.be>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, xiaosuo@gmail.com, netdev@vger.kernel.org
To: bdschuym@pandora.be
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46722
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750954Ab0HCAZD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Aug 2010 20:25:03 -0400
In-Reply-To: <4C571A70.20103@pandora.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bart De Schuymer <bdschuym@pandora.be>
Date: Mon, 02 Aug 2010 21:20:16 +0200

> Patrick McHardy schreef:
>> On 01.08.2010 01:25, Changli Gao wrote:
>>   
>>> 6c79bf0f2440fd250c8fce8d9b82fcf03d4e8350 subtracts PPPOE_SES_HLEN from
>>> mtu at
>>> the front of ip_fragment(). So the later subtraction should be
>>> removed. The
>>> MTU of 802.1q is also 1500, so MTU should not be changed.
 ...
> Signed-off-by: Bart De Schuymer <bdschuym@pandora.bo>
>>> Signed-off-by: Changli Gao <xiaosuo@gmail.com>

Applied, thanks everyone.
