From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 0/3 v3] macvtap driver
Date: Wed, 27 Jan 2010 22:59:31 +0100
Message-ID: <201001272259.31158.arnd@arndb.de>
References: <201001271104.20607.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	Patrick McHardy <kaber@trash.net>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Or Gerlitz <ogerlitz@voltaire.com>, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.187]:58358 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756102Ab0A0V7q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jan 2010 16:59:46 -0500
In-Reply-To: <201001271104.20607.arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 27 January 2010, Arnd Bergmann wrote:
> There are still known problems, but unless there
> are fundamental concerns, I'd like this to go
> into net-next as an experimental driver,
> fixing up the remaining problems by 2.6.34-rc1.

I should have been more specific here. The one
really annoying problem is a reference counting
problem I introduced in one of the last changes
that prevents you from destroying a device after
it has been used.

Unfortunately, I'm still traveling after LCA,
and haven't had a chance to look into this before
sending out the patches as I had originally
planned. I've also seen crashes that are not
fully reproducible, any bug reports on those
are appreciated.

	Arnd
