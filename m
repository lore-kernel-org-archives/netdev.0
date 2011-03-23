From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 08/16] mlx4_en: Reporting HW revision in ethtool -i
Date: Wed, 23 Mar 2011 12:36:43 -0700 (PDT)
Message-ID: <20110323.123643.200348134.davem@davemloft.net>
References: <4D89B16F.4040008@mellanox.co.il>
	<1300889054.26693.527.camel@localhost>
	<953B660C027164448AE903364AC447D20705BE28@mtldag01.mtl.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, netdev@vger.kernel.org,
	eugenia@mellanox.co.il
To: yevgenyp@mellanox.co.il
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39809
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932802Ab1CWTgF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Mar 2011 15:36:05 -0400
In-Reply-To: <953B660C027164448AE903364AC447D20705BE28@mtldag01.mtl.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Date: Wed, 23 Mar 2011 15:10:34 +0000

>> 
>> This is an abuse of the ethtool_drvinfo::driver field.
>> 
>> Your users can use lspci -v, can't they?
>> 
> I don't think there is a problem here.
> We have always reported the HW model via Ethtool, we just expanded the information
> we provide.
> Our users prefer to see the information in ethtool.

This doesn't matter, we strive for consistency across drivers rather
than have special cases like this.

Please remove the chip variant information from the ethtool driver
string, it is absolutely not appropriate.
