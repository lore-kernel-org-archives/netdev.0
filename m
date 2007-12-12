From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 7/8][BNX2]: Enable S/G for jumbo RX.
Date: Wed, 12 Dec 2007 11:20:07 -0800 (PST)
Message-ID: <20071212.112007.235610421.davem@davemloft.net>
References: <1197486011.16386.32.camel@dell>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52374
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752174AbXLLTUI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Dec 2007 14:20:08 -0500
In-Reply-To: <1197486011.16386.32.camel@dell>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Wed, 12 Dec 2007 11:00:11 -0800

> [BNX2]: Enable S/G for jumbo RX.
> 
> If the MTU requires more than 1 page for the SKB, enable the page ring
> and calculate the size of the page ring.  This will guarantee order-0
> allocation regardless of the MTU size.
> 
> Fixup loopback test packet size so that we don't deal with the pages
> during loopback test.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied.
