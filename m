From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 5/5] qed*: Add support for read/write of eeprom
Date: Mon, 18 Apr 2016 00:07:12 -0400 (EDT)
Message-ID: <20160418.000712.473871996964045833.davem@davemloft.net>
References: <1460921195-23352-6-git-send-email-Yuval.Mintz@qlogic.com>
	<20160417.191849.2044093416855662399.davem@davemloft.net>
	<CO2PR11MB0088716755CC57276455ADA4976B0@CO2PR11MB0088.namprd11.prod.outlook.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Sudarsana.Kalluru@qlogic.com
To: Yuval.Mintz@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47963 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750769AbcDREHQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Apr 2016 00:07:16 -0400
In-Reply-To: <CO2PR11MB0088716755CC57276455ADA4976B0@CO2PR11MB0088.namprd11.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Date: Mon, 18 Apr 2016 03:59:42 +0000

> The third option I see is to completely ditch this, stating that although
> We obviously CAN set the non-volatile memory we CAN'T do it with the
> regular API, and to move into doing this via some proprietary API such
> as debugfs.

Why go to debugfs rather than gracefully extending the ethtool stuff to
explicitly support what you need?

Anyone who says debugfs just isn't willing to design things correctly.

That's why I basically have started rejecting everything that tries
to use debugfs in the networking, it's the "I'm too damn lazy to
do this properly" option and I simply won't stand for crap like that
any more.
