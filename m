From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 0/9] network driver fixes
Date: Fri, 29 Jan 2016 13:56:16 +0100
Message-ID: <3029473.9UEV1vNhFu@wuerfel>
References: <1453903507-3427225-1-git-send-email-arnd@arndb.de> <20160128.161413.1463071323452305953.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: linux-arm-kernel@lists.infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.126.131]:58843 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755428AbcA2M4s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jan 2016 07:56:48 -0500
In-Reply-To: <20160128.161413.1463071323452305953.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 28 January 2016 16:14:13 David Miller wrote:
> From: Arnd Bergmann <arnd@arndb.de>
> Date: Wed, 27 Jan 2016 15:04:50 +0100
> 
> > These are all fixes for relatively harmless bugs that showed up
> > in my randconfig testing, so they should not be needed for v4.5
> > but get merged into net-next.
> > 
> > I've managed to address all 'uninitialized variable' warnings that
> > I get in ARM randconfig kernels now, this series includes the
> > last five I got in network drivers. They are often really annoying
> > warnings but when we get new ones, they often are about actual
> > bugs in corner cases, so I'm trying hard to eliminate the false
> > positives here to get people to pay attention to added warnings.
> > I've recently tried building with an older gcc and found tons more
> > that are all bogus, this series only addresses the ones that
> > gcc-5.2 finds.
> 
> Arnd I'm expecting a respin of this series to address with the
> feedback you've been given.
> 

Done. I wasn't sure if you planned to pick up the patches
individually, thanks for the clarification.

	Arnd
