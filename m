From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: mvneta: properly disable HW PHY polling and
 ensure adjust_link() works
Date: Thu, 05 Sep 2013 14:51:13 -0400 (EDT)
Message-ID: <20130905.145113.3434775203310652.davem@davemloft.net>
References: <1378304478-21237-1-git-send-email-thomas.petazzoni@free-electrons.com>
	<20130904145051.GO19598@titan.lakedaemon.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: thomas.petazzoni@free-electrons.com, netdev@vger.kernel.org,
	alior@marvell.com, jochen.armkernel@leahnim.org,
	simon.guinot@sequanux.org, ryan@presslab.us, vdonnefort@lacie.com,
	ethan@ethantuttle.com, stable@vger.kernel.org,
	ezequiel.garcia@free-electrons.com, yves@cheny.fr,
	gregory.clement@free-electrons.com, psanford@nearbuy.io, w@1wt.eu,
	linux-arm-kernel@lists.infradead.org
To: jason@lakedaemon.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38904 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752942Ab3IESvQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Sep 2013 14:51:16 -0400
In-Reply-To: <20130904145051.GO19598@titan.lakedaemon.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jason Cooper <jason@lakedaemon.net>
Date: Wed, 4 Sep 2013 10:50:51 -0400

> On Wed, Sep 04, 2013 at 04:21:18PM +0200, Thomas Petazzoni wrote:
>> This commit fixes a long-standing bug that has been reported by many
>> users: on some Armada 370 platforms, only the network interface that
>> has been used in U-Boot to tftp the kernel works properly in
>> Linux. The other network interfaces can see a 'link up', but are
>> unable to transmit data. The reports were generally made on the Armada
>> 370-based Mirabox, but have also been given on the Armada 370-RD
>> board.
 ...
> 
> David,
> 
> Offending patch is:
> 
>   c5aff18 net: mvneta: driver for Marvell Armada 370/XP network unit
> 
> Applies and builds cleanly against v3.8.13, v3.9.11, v3.10.10, and v3.11
> 
> Acked-by: Jason Cooper <jason@lakedaemon.net>

Applied.
