From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/42] Kill -Wunused-but-set warnings
Date: Sun, 17 Apr 2011 20:38:35 -0700 (PDT)
Message-ID: <20110417.203835.193727585.davem@davemloft.net>
References: <20110417.173233.193710905.davem@davemloft.net>
	<1303093155.5282.1009.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50933
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751923Ab1DRDjK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Apr 2011 23:39:10 -0400
In-Reply-To: <1303093155.5282.1009.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Mon, 18 Apr 2011 03:19:15 +0100

> In most of these cases there is presumably no need for the variable at
> all.  In others, the variable should have been used - which I believe is
> the main reason for the warning - and by removing it you will be hiding
> a bug.

If you look at about 5 or 6 of my patches, that's exactly what I did,
make use of the variable.

Otherwise I tossed it.

It seems I messed up the decnet case, which I'll fix shortly.
