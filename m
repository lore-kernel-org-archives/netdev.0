From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: Keystone 2 boards boot failure
Date: Tue, 02 Feb 2016 21:41:22 +0100
Message-ID: <4387314.e6bS94RE4H@wuerfel>
References: <56B0DE61.2000704@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: m-karicheri2@ti.com, netdev@vger.kernel.org, w-kwok2@ti.com,
	davem@davemloft.net
To: "Franklin S Cooper Jr." <fcooper@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.17.13]:60545 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752733AbcBBUlc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Feb 2016 15:41:32 -0500
In-Reply-To: <56B0DE61.2000704@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 02 February 2016 10:50:41 Franklin S Cooper Jr. wrote:
> Latest mainline is currently failing to boot for Keystone 2
> Hawking but I'm assuming its true for other Keystone 2
> boards. Bisect shows that this issue popped up after the
> patch "netcp: try to reduce type confusion in descriptors"
> (commit 89907779) was introduced. There was another patch
> "netcp: fix regression in receive processing" that seems to
> fix some bugs that the prior patch introduced however it
> still did not resolve the boot failure and was documented as
> not being tested.
> 
> Should we revert these commits or does anyone have any
> suggestions on how to fix these failures? I would be more
> than happy to test any fix.
> 

Have you tried to see if a revert fixes the problem on a
current kernel?

	Arnd
