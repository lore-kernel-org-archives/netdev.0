From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] phy: micrel: Fix finding PHY properties in MAC
 node for KSZ9031.
Date: Wed, 23 Dec 2015 11:37:38 -0500 (EST)
Message-ID: <20151223.113738.1936313727845564774.davem@davemloft.net>
References: <20151222110634.GC2373@lunn.ch>
	<20151222.171444.1073714139867888727.davem@davemloft.net>
	<567A572A.4030207@ginzinger.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andrew@lunn.ch, f.fainelli@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: henri.roosen@ginzinger.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36119 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750969AbbLWQhk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Dec 2015 11:37:40 -0500
In-Reply-To: <567A572A.4030207@ginzinger.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Henri Roosen <henri.roosen@ginzinger.com>
Date: Wed, 23 Dec 2015 09:11:22 +0100

> On 12/22/2015 11:14 PM, David Miller wrote:
>> From: Andrew Lunn <andrew@lunn.ch>
>> Date: Tue, 22 Dec 2015 12:06:34 +0100
>>
>>> On Tue, Dec 22, 2015 at 11:58:40AM +0100, Henri Roosen wrote:
>>>> Commit 651df2183543 ("phy: micrel: Fix finding PHY properties in MAC
>>>>   node.") only fixes finding PHY properties in MAC node for
>>>>   KSZ9021. This
>>>> commit applies the same fix for KSZ9031.
>>>>
>>>> Signed-off-by: Henri Roosen <henri.roosen@ginzinger.com>
>>>
>>> Fixes: 8b63ec1837fa ("phylib: Make PHYs children of their MDIO bus,
>>> not the bus' parent.")
>>>
>>> Acked-by: Andrew Lunn <andrew@lunn.ch>
>>
>> This does not apply cleanly to any of my trees.
> 
> David, does the original patch not apply cleanly or is your comment
> only
> on the message from Andrew?
> 
> Else please let me know what is wrong with the original patch. I've
> tested it applies cleanly to v4.4-rc6 and to v4.3.

Your original patch did not apply cleanly.

All patches must be against either my 'net' or 'net-next' trees.  And
you must explicitly state what tree your patch is against and therefore
which tree you expect me to apply it too.
