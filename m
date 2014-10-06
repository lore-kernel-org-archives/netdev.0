From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: bcmgenet: improve bcmgenet_mii_setup()
Date: Mon, 06 Oct 2014 00:18:40 -0400 (EDT)
Message-ID: <20141006.001840.1053267802558927782.davem@davemloft.net>
References: <20141003192501.C79311004A1@puck.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, f.fainelli@gmail.com
To: pgynther@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57588 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750720AbaJFESo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Oct 2014 00:18:44 -0400
In-Reply-To: <20141003192501.C79311004A1@puck.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Petri Gynther <pgynther@google.com>
Date: Fri,  3 Oct 2014 12:25:01 -0700 (PDT)

> bcmgenet_mii_setup() is called from the PHY state machine every 1-2 seconds
> when the PHYs are in PHY_POLL mode.
> 
> Improve bcmgenet_mii_setup() so that it touches the MAC registers only when
> the link is up and there was a change to link, speed, duplex, or pause status.
> 
> Signed-off-by: Petri Gynther <pgynther@google.com>

Yeah that's ugly reprogramming so much stuff unnecessarily every
second or two, applied thanks.
