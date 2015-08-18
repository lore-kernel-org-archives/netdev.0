From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/3] D in DSA patches
Date: Tue, 18 Aug 2015 14:17:39 -0700 (PDT)
Message-ID: <20150818.141739.626644412182774808.davem@davemloft.net>
References: <1439848372-4055-1-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux@roeck-us.net, f.fainelli@gmail.com,
	vivien.didelot@savoirfairelinux.com, netdev@vger.kernel.org
To: andrew@lunn.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42508 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751349AbbHRVRk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Aug 2015 17:17:40 -0400
In-Reply-To: <1439848372-4055-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Lunn <andrew@lunn.ch>
Date: Mon, 17 Aug 2015 23:52:49 +0200

> The D in DSA is distributed, meaning multiple switches can be
> connected together. Currently no mainline system does this, and so the
> code is broken. This patchset contains two fixes, and a small helper.
> 
> With three of more switches, the current device tree binding is not
> sufficient to express the routing between the switches. The first
> patch extends the binding, in a backwards compatible way, to allow a
> link between a switch to describe all the switches accessible over the
> link, not just the direct neighbor.
> 
> The third patch fixes the port configuration on newer devices for
> links connecting switches.

Series applied, thanks Andrew.
