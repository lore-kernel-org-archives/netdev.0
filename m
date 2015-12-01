From: David Miller <davem@davemloft.net>
Subject: Re: IPv4 tunnels: why IP-IP and SIT enforce DF bit, but GRE does
 not?
Date: Tue, 01 Dec 2015 12:08:51 -0500 (EST)
Message-ID: <20151201.120851.2159228528635979581.davem@davemloft.net>
References: <1448964929.3305540.454487369.098BD535@webmail.messagingengine.com>
	<565D9EB6.1080102@shemyak.com>
	<1448976655.3349108.454655833.599EFE94@webmail.messagingengine.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: konstantin@shemyak.com, netdev@vger.kernel.org, pshelar@nicira.com
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53542 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756131AbbLARIz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Dec 2015 12:08:55 -0500
In-Reply-To: <1448976655.3349108.454655833.599EFE94@webmail.messagingengine.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Tue, 01 Dec 2015 14:30:55 +0100

> On Tue, Dec 1, 2015, at 14:20, Konstantin Shemyak wrote:
>> My point was not to question its feasibility, but to make it similar 
>> across GRE, IP-IP and SIT tunnels.
> 
> I would send a patch to add it again if Parvin didn't have good reasons
> to remove it.

The tunnel code consolidation created a lot of regressions and subtle
unintended changes in behavior between the different tunnel types.

This DF bit issue is just yet another example of that.

I'm really disappointed at how many bugs and problems were introduced
by those changes.
