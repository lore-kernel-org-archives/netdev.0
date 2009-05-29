From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/5] netdev: bfin_mac: Blackfin EMAC interrupt may not
 be shared
Date: Fri, 29 May 2009 02:01:22 -0700 (PDT)
Message-ID: <20090529.020122.110502272.davem@davemloft.net>
References: <1243404615-25879-1-git-send-email-vapier@gentoo.org>
	<1243404615-25879-2-git-send-email-vapier@gentoo.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, uclinux-dist-devel@blackfin.uclinux.org,
	michael.hennerich@analog.com, cooloney@kernel.org
To: vapier@gentoo.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37659
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754065AbZE2JBW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 May 2009 05:01:22 -0400
In-Reply-To: <1243404615-25879-2-git-send-email-vapier@gentoo.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mike Frysinger <vapier@gentoo.org>
Date: Wed, 27 May 2009 02:10:11 -0400

> From: Michael Hennerich <michael.hennerich@analog.com>
> 
> Signed-off-by: Michael Hennerich <michael.hennerich@analog.com>
> Signed-off-by: Mike Frysinger <vapier@gentoo.org>
> Signed-off-by: Bryan Wu <cooloney@kernel.org>

I'm not applying this.

Either take the time to make this interrupt handler cope with shared
interrupts (the most preferred) or take the time to write an
excruciatingly long winded and explicit commit log message explaining
why that's not possible.

And I want the commit log message path to be as painful as possible so
that you choose to fix this driver's IRQ handler to behave sanely
instead. :-)
