From: David Miller <davem@davemloft.net>
Subject: Re: [5/5][BNX2]: Update version and reldate.
Date: Mon, 04 Jun 2007 21:26:00 -0700 (PDT)
Message-ID: <20070604.212600.91329859.davem@davemloft.net>
References: <1181001678.5275.16.camel@dell>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andy@greyhouse.net, netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44989
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754475AbXFEEZq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jun 2007 00:25:46 -0400
In-Reply-To: <1181001678.5275.16.camel@dell>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Michael Chan" <mchan@broadcom.com>
Date: Mon, 04 Jun 2007 17:01:18 -0700

> [BNX2]: Update version and reldate.
> 
> Update to version 1.5.11.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Also applied.

I'd like to note in passing since I saw it in the context of this diff
that I find the RUN_AT() macro confusing.

It's name implies that the argument given to it is absolute.  Instead,
the argument is relative and it's return value is absolute.

Maybe it's just me :-)
