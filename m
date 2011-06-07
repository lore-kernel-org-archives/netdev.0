From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [RFC] should we care of COMPAT mode in bridge ?
Date: Tue, 7 Jun 2011 16:54:21 -0700
Message-ID: <20110607165421.68760205@s6510.ftrdhcpuser.net>
References: <201106062206.29134.arnd@arndb.de>
	<20110606.130958.1488166895702555231.davem@davemloft.net>
	<201106062219.33432.arnd@arndb.de>
	<20110606.132315.1222364671200899036.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: arnd@arndb.de, eric.dumazet@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:46746 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753498Ab1FGXyd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Jun 2011 19:54:33 -0400
In-Reply-To: <20110606.132315.1222364671200899036.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 06 Jun 2011 13:23:15 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: Arnd Bergmann <arnd@arndb.de>
> Date: Mon, 6 Jun 2011 22:19:33 +0200
> 
> > I think it would be good to first understand why it doesn't work with the
> > new style ioctls that are in the kernel. The source code of brctl that
> > I'm looking at here contains:
> 
> Eric's 32-bit binary was built against older headers that didn't
> define the new ioctls.
> 
> That makes it pretty clear to me that we have to support those
> older ioctls in compat mode even after all these years.

That is really old, even Debian Lenny isn't that out of date.
