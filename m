From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] syncookies: do not store rcv_wscale in tcp
 timestamp
Date: Sat, 26 Jun 2010 21:27:23 -0700 (PDT)
Message-ID: <20100626.212723.63040028.davem@davemloft.net>
References: <20100623202759.GA3581@nuttenaction>
	<20100624075304.GH27132@Chamillionaire.breakpoint.cc>
	<20100624221416.GA31116@nuttenaction>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fw@strlen.de, netdev@vger.kernel.org, ilpo.jarvinen@helsinki.fi
To: hagen@jauu.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41503
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750925Ab0F0E1K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Jun 2010 00:27:10 -0400
In-Reply-To: <20100624221416.GA31116@nuttenaction>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hagen Paul Pfeifer <hagen@jauu.net>
Date: Fri, 25 Jun 2010 00:14:16 +0200

> why not limit the window to 2^16 bytes which is sufficient for
> 99.9999% of the use case?

This may have been true 8 years ago, but it is not any longer.

You will underutilize your link with anything smaller than
~512k on the modern internet.
