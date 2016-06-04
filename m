From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 00/17] New DSA bind, switches as devices
Date: Fri, 03 Jun 2016 22:41:51 -0700 (PDT)
Message-ID: <20160603.224151.1241265944196710098.davem@davemloft.net>
References: <1464972256-10408-1-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vivien.didelot@savoirfairelinux.com, f.fainelli@gmail.com,
	netdev@vger.kernel.org
To: andrew@lunn.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45539 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750718AbcFDFlz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Jun 2016 01:41:55 -0400
In-Reply-To: <1464972256-10408-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Lunn <andrew@lunn.ch>
Date: Fri,  3 Jun 2016 18:43:59 +0200

> The interesting patches here are the last three. They implement a new
> binding for DSA, which removes a few limitations of the current DSA
> binding. In particular, it allows switches to be true Linux devices.
> These devices can be on any type of bus, unlike the old DSA binding
> which assumes MDIO. See the commit log for more details. The second to
> last patch modifies an existing boards device tree to use the new
> binding, giving a good example of how switches can be true MDIO
> devices. The last patch documents the new binding.
> 
> I know both John Crispin and Bryan Whitehead are interesting in
> implementing DSA drivers, hence i have CC: you. Comments welcome.
> 
> Thanks go to Florian and Vivien for reviewing, testing and bug fixing
> these patches.

Florian's feedback wrt. patch #15 seems legitimate.  Please address
and respin this series, it looks ready to go.
