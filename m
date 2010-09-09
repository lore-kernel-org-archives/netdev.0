From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] cxacru: ignore cx82310_eth devices
Date: Wed, 08 Sep 2010 23:07:47 -0700 (PDT)
Message-ID: <20100908.230747.71591658.davem@davemloft.net>
References: <20100908.131227.28827971.davem@davemloft.net>
	<201009082252.15865.linux@rainbow-software.org>
	<20100909033557.GA3723@kroah.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux@rainbow-software.org, simon@fire.lp0.eu,
	dbrownell@users.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: greg@kroah.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50353
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750996Ab0IIGH3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Sep 2010 02:07:29 -0400
In-Reply-To: <20100909033557.GA3723@kroah.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg KH <greg@kroah.com>
Date: Wed, 8 Sep 2010 20:35:57 -0700

> On Wed, Sep 08, 2010 at 10:52:12PM +0200, Ondrej Zary wrote:
>> Ignore ADSL routers, which can have the same vendor and product IDs
>> as ADSL modems but should be handled by the cx82310_eth driver.
>> 
>> This intentionally ignores device IDs that aren't currently handled
>> by cx82310_eth. There may be other device IDs that perhaps shouldn't
>> be claimed by cxacru.
> 
> Looks good, thanks, I'll go queue it up.

Greg, see my reply, I already tossed this into net-next-2.6
