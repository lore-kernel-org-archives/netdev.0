From: David Miller <davem@davemloft.net>
Subject: Re: bnx2 dirver's firmware images
Date: Tue, 18 Sep 2007 11:23:37 -0700 (PDT)
Message-ID: <20070918.112337.74737433.davem@davemloft.net>
References: <200709181823.26429.vda.linux@googlemail.com>
	<1190141114.9540.216.camel@dell>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vda.linux@googlemail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-98-Washington.hfc.comcastbusiness.net ([74.93.104.98]:42123
	"EHLO picasso.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753563AbXIRSXp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Sep 2007 14:23:45 -0400
In-Reply-To: <1190141114.9540.216.camel@dell>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Michael Chan" <mchan@broadcom.com>
Date: Tue, 18 Sep 2007 11:45:14 -0700

> On Tue, 2007-09-18 at 18:23 +0100, Denys Vlasenko wrote:
> > Do you have any plans to switch to request_firmware() interface,
> > which will allow you to avoid keeping firmware in unswappable kernel
> > memory and thus free ~80k?
> 
> Matching the correct version of the firmware with the driver is the main
> issue.
> 
> David, what's your opinion on this?

I don't like it because it means people have to setup full initrd's
in order to do network booting with such network cards.

But the days of my opinion mattering on that issue are long gone,
the momentum is just too greatly behind using request_firmware()
across the board, so there is no reason for bnx2 to be any different.
