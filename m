From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: irda: irttp: sync error paths of data- and
 udata-requests
Date: Thu, 18 Nov 2010 12:24:51 -0800 (PST)
Message-ID: <20101118.122451.191398084.davem@davemloft.net>
References: <20101116.095101.115945762.davem@davemloft.net>
	<1289936402-25277-1-git-send-email-w.sang@pengutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sameo@linux.intel.com
To: w.sang@pengutronix.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51621
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756773Ab0KRUY2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Nov 2010 15:24:28 -0500
In-Reply-To: <1289936402-25277-1-git-send-email-w.sang@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wolfram Sang <w.sang@pengutronix.de>
Date: Tue, 16 Nov 2010 20:40:02 +0100

> irttp_data_request() returns meaningful errorcodes, while irttp_udata_request()
> just returns -1 in similar situations. Sync the two and the loglevels of the
> accompanying output.
> 
> Signed-off-by: Wolfram Sang <w.sang@pengutronix.de>
> Cc: Samuel Ortiz <sameo@linux.intel.com>
> Cc: David Miller <davem@davemloft.net>
> ---
> 
> Thank you David for picking up the zero-byte-packet-patch. Now as it was
> applied, this one might be interesting, too (on top of it)? Nothing seriously
> needed, but looks more proper IMHO. LXR says that are callers of these
> functions check with < 0 anyhow.

Better error code reporting is always appreciated :-)

Applied, thanks.
