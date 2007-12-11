From: David Miller <davem@davemloft.net>
Subject: Re: [patch 2/5] ipv6: make extended headers to return an error at
 initialization
Date: Tue, 11 Dec 2007 02:24:05 -0800 (PST)
Message-ID: <20071211.022405.16660761.davem@davemloft.net>
References: <20071210150910.440970057@ICON-9-164-138-215.megacenter.de.ibm.com>
	<20071210151431.005904948@ICON-9-164-138-215.megacenter.de.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, pekkas@netcore.fi, netdev@vger.kernel.org
To: dlezcano@fr.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48364
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751757AbXLKKYG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Dec 2007 05:24:06 -0500
In-Reply-To: <20071210151431.005904948@ICON-9-164-138-215.megacenter.de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Lezcano <dlezcano@fr.ibm.com>
Date: Mon, 10 Dec 2007 16:09:12 +0100

> This patch factorize the code for the differents init functions for rthdr,
> nodata, destopt in a single function exthdrs_init.
> This function returns an error so the af_inet6 module can check correctly
> the initialization.
> 
> Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>

Applied.
