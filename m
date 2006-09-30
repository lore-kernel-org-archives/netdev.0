From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 0/6]: powerpc/cell spidernet ethernet patches
Date: Sat, 30 Sep 2006 12:40:00 +0200
Message-ID: <200609301240.03464.arnd@arndb.de>
References: <20060929230552.GG6433@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Linas Vepstas <linas@austin.ibm.com>, jeff@garzik.org,
	akpm@osdl.org, netdev@vger.kernel.org,
	James K Lewis <jklewis@us.ibm.com>,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.183]:49659 "EHLO
	moutng.kundenserver.de") by vger.kernel.org with ESMTP
	id S1750782AbWI3KkK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 30 Sep 2006 06:40:10 -0400
To: linuxppc-dev@ozlabs.org
In-Reply-To: <20060929230552.GG6433@austin.ibm.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am Saturday 30 September 2006 01:05 schrieb Linas Vepstas:
> Although these patches have not been baking in
> any -mm tree, they have been tested and are
> generally available as a part of the Cell SDK 2.0
> overseen by Arnd Bergmann. (Arnd, if you want
> to lend a voice of authority here, or to correct
> me, please do so...)
>
> The following sequence of six patches implement a
> series of changes to the transmit side of the
> spidernet ethernet device driver, significantly
> improving performance for large packets.
>
> This series of patches is almost identical to
> those previously mailed on 18-20 August, with one
> critical change: NAPI polling is used instead of
> homegrown polling.
>
> Although these patches improve things, I am not
> satisfied with how this driver behaves, and so
> plan to do additional work next week.
>

I'm not sure if I have missed a patch in here, but I
don't see anything reintroducing the 'netif_stop_queue'
that is missing from the transmit path.

Do you have a extra patch for that?

	Arnd <><
