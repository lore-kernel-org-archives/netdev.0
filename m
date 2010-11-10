From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Prevent reading uninitialized memory with socketfilters
Date: Wed, 10 Nov 2010 10:21:29 -0800 (PST)
Message-ID: <20101110.102129.112602843.davem@davemloft.net>
References: <1695276347-1289413089-cardhu_decombobulator_blackberry.rim.net-434693855-@bda083.bisx.prod.on.blackberry>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stable@kernel.org, security@kernel.org
To: drosenberg@vsecurity.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35564
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754215Ab0KJSVF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Nov 2010 13:21:05 -0500
In-Reply-To: <1695276347-1289413089-cardhu_decombobulator_blackberry.rim.net-434693855-@bda083.bisx.prod.on.blackberry>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Dan Rosenberg" <drosenberg@vsecurity.com>
Date: Wed, 10 Nov 2010 18:18:08 +0000

> The code sample I linked to clearly demonstrates exactly how to
> accomplish this, if you had bothered to read it.

I told you why I didn't read it, if you had bothered to read my
reply properly :-)

Anyways, I realize we have to do something, but memset() is going
to completely kill performance.  I consider Eric's suggestion the
closest to acceptable cost at this point but even that is hard
to digest for me.
