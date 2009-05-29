From: David Miller <davem@davemloft.net>
Subject: Re: [Uclinux-dist-devel] [PATCH 1/5] netdev: bfin_mac: Blackfin
 EMAC interrupt may not be shared
Date: Fri, 29 May 2009 03:53:44 -0700 (PDT)
Message-ID: <20090529.035344.92579416.davem@davemloft.net>
References: <1243404615-25879-2-git-send-email-vapier@gentoo.org>
	<20090529.020122.110502272.davem@davemloft.net>
	<8bd0f97a0905290349p6f52d170i3714cd3ec0c81817@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, michael.hennerich@analog.com,
	uclinux-dist-devel@blackfin.uclinux.org
To: vapier.adi@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38598
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757538AbZE2Kxo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 May 2009 06:53:44 -0400
In-Reply-To: <8bd0f97a0905290349p6f52d170i3714cd3ec0c81817@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mike Frysinger <vapier.adi@gmail.com>
Date: Fri, 29 May 2009 06:49:42 -0400

> the hardware has a dedicated internal IRQ line for the Blackfin MAC.
> it makes no sense to mark it as shared.  there is nothing it could
> possibly be shared with.

Then why bother messing with the flag away at all?  It doesn't fix
anything.
