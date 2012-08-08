From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 0/7] mv643xx.c: Add basic device tree support.
Date: Wed, 08 Aug 2012 01:59:51 -0700 (PDT)
Message-ID: <20120808.015951.1224491744100458448.davem@davemloft.net>
References: <1344350092-24050-1-git-send-email-ian.molton@codethink.co.uk>
	<20120807.162923.34400427265666163.davem@davemloft.net>
	<201208080816.29218.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ian.molton@codethink.co.uk, linux-arm-kernel@lists.infradead.org,
	andrew@lunn.ch, thomas.petazzoni@free-electrons.com,
	ben.dooks@codethink.co.uk, netdev@vger.kernel.org
To: arnd@arndb.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38965 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752470Ab2HHI7y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Aug 2012 04:59:54 -0400
In-Reply-To: <201208080816.29218.arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arnd Bergmann <arnd@arndb.de>
Date: Wed, 8 Aug 2012 08:16:28 +0000

> On Tuesday 07 August 2012, David Miller wrote:
>> From: Ian Molton <ian.molton@codethink.co.uk>
>> Date: Tue,  7 Aug 2012 15:34:45 +0100
>> 
>> > Fixed all comments.
>> > 
>> > * Dropped csb1724 defconfig.
>> > * Added patch to remove MV643XX_ETH_SHARED_NAME and MV643XX_ETH_NAME
>> > * Dropped un-necessary D-T irq fixup code
>> 
>> Who is going to take this series?
> 
> I'd prefer to take the entire series through the arm-soc tree from
> the kirkwood maintainers. We first have to work out the bindings
> though, since the current patch introduces a new one that is
> incompatible with the one we were using on powerpc with
> open firmware before.

Ok.
