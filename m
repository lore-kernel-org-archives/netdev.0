From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2.6.32 2/3] net: Fix ks8851 snl transmit problem
Date: Thu, 03 Dec 2009 16:03:18 -0800 (PST)
Message-ID: <20091203.160318.62214993.davem@davemloft.net>
References: <14385191E87B904DBD836449AA30269D021A41@MORGANITE.micrel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ben@simtec.co.uk, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Tristram.Ha@Micrel.Com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38362
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753080AbZLDADL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2009 19:03:11 -0500
In-Reply-To: <14385191E87B904DBD836449AA30269D021A41@MORGANITE.micrel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Ha, Tristram" <Tristram.Ha@Micrel.Com>
Date: Thu, 3 Dec 2009 13:17:48 -0800

> This fixes a transmit problem of the ks8851 snl network driver.  Under heavy TCP traffic the device will stop transmitting.  Turning off the transmit interrupt avoids this issue.  A new workqueue was implemented to replace the functionality of the transmit interrupt processing.
> 
> Signed-off-by: Tristram Ha <Tristram.Ha@micrel.com>

Please describe why the TX interrupt facility cannot be used.
You probably have a race condition or similar, have you tried
to see if there is some issue like that?

This workqueue is going to make performance terrible, at best.
