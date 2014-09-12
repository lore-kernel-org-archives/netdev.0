From: David Miller <davem@davemloft.net>
Subject: Re: RFC: DSA device/driver model revamp
Date: Fri, 12 Sep 2014 17:50:22 -0400 (EDT)
Message-ID: <20140912.175022.8867946355734452.davem@davemloft.net>
References: <5410CCA6.8080506@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jogo@openwrt.org, nbd@openwrt.org,
	alexander.duyck@gmail.com, jhs@mojatatu.com, kernel@wantstofly.org
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51628 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752869AbaILVuZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Sep 2014 17:50:25 -0400
In-Reply-To: <5410CCA6.8080506@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Wed, 10 Sep 2014 15:11:50 -0700

> Proposed solution:

No objections from me.

> Open questions:
> 
> There is some legacy code that will instantiate the special "dsa"
> platform device in arch/arm/mach-orion5x/*, this code needs to be
> transitioned one way or the other.
> 
> The switches used by these Orion5x platforms are MDIO-connected
> switches, with the proposal above, these switch drivers will become PHY
> drivers matching a particular PHY ID on the MDIO bus.
> 
> We currently do not have a way to attach platform specific data that is
> not coming from Device Tree to these PHY devices, something potentially
> not too intrusive could be to extend phy_register_fixup() with a void *
> argument to pass specific platform data, or create
> phy_register_fixup_with_data().

I'd rather you create a new interface which is strongly typed than
anything using void pointers.
