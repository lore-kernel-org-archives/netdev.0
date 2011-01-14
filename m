From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 03/10] GRETH: added no_gbit option
Date: Thu, 13 Jan 2011 22:13:24 -0800 (PST)
Message-ID: <20110113.221324.82807816.davem@davemloft.net>
References: <1294907135-24884-1-git-send-email-daniel@gaisler.com>
	<1294907135-24884-3-git-send-email-daniel@gaisler.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kristoffer@gaisler.com
To: daniel@gaisler.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46329
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750859Ab1ANGMw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Jan 2011 01:12:52 -0500
In-Reply-To: <1294907135-24884-3-git-send-email-daniel@gaisler.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Hellstrom <daniel@gaisler.com>
Date: Thu, 13 Jan 2011 09:25:28 +0100

> For debug only. The driver does not report that it is GBit capable, instead
> it will report 10/100 mode to the generic PHY layer.
> 
> Signed-off-by: Daniel Hellstrom <daniel@gaisler.com>

You may not add special purpose module parameters to your ethernet driver.

Instead, users can use ethtool to control what speeds the device will
try to advertise for during auto-negotiation, or use with a fixed
link configuration.
