From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] IP checksuming doesn't work on GE0301 option cards
Date: Thu, 09 Dec 2010 20:43:00 -0800 (PST)
Message-ID: <20101209.204300.183050064.davem@davemloft.net>
References: <20101208082152.407022397DD@solo.franken.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, j.dumon@option.com
To: tsbogend@alpha.franken.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58031
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755273Ab0LJEmc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Dec 2010 23:42:32 -0500
In-Reply-To: <20101208082152.407022397DD@solo.franken.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Bogendoerfer <tsbogend@alpha.franken.de>
Date: Wed,  8 Dec 2010 09:21:52 +0100 (CET)

> There is definitly a problem, that some option cards send up broken
> IP pakets leading to corrupted IP packets. These corruptions aren't
> detected, because the driver claims that the packets are already
> checksummed. This change removes the CHECKSUM_UNNECESSARY option
> and let IP detect broken data.
> 
> Signed-off-by: Thomas Bogendoerfer <tsbogend@alpha.franken.de>

Applied, thank you.
