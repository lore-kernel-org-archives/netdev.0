From: Jan Engelhardt <jengelh@computergmbh.de>
Subject: Re: [PATCH] CONFIG_NET=n - lots of link time errors
Date: Sun, 22 Jul 2007 12:10:38 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0707221206280.15705@fbirervta.pbzchgretzou.qr>
References: <Pine.LNX.4.64.0707211817490.21737@fbirervta.pbzchgretzou.qr>
 <20070721.191223.15264470.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	akpm@linux-foundation.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sovereign.computergmbh.de ([85.214.69.204]:49941 "EHLO
	sovereign.computergmbh.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750714AbXGVKKj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Jul 2007 06:10:39 -0400
In-Reply-To: <20070721.191223.15264470.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Jul 21 2007 19:12, David Miller wrote:
>> Enabling drivers from "Devices > Networking" (in menuconfig), for 
>> example SLIP and/or PLIP, throws link time errors when CONFIG_NET itself 
>> is =n. Have CONFIG_NETDEVICES depend on CONFIG_NET.
>> 
>> Signed-off-by: Jan Engelhardt <jengelh@gmx.de>
>
>This is the second time I've seen this change in the past few
>days, and people seem to hit it quite readily with randconfig.
>
>It seems reasonable and I'll apply it, thanks Jan.

While randconfig is nice and good, this error actually came by manually
tuning the .config for a specific goal (namely: make a small kernel for an
ancient i386 without modifying any code). Turning off CONFIG_NET
was then just an idea away, because I knew that TCP was quite big.


	Jan
-- 
