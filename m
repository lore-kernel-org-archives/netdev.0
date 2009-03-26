From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bridge: bad error handling when adding invalid ether
 address
Date: Wed, 25 Mar 2009 21:01:54 -0700 (PDT)
Message-ID: <20090325.210154.102979690.davem@davemloft.net>
References: <062c01c9adb4$c12a8e80$b100000a@Stig>
	<20090325205700.1a4a7fd6@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stig@vyatta.com, netdev@vger.kernel.org, stable@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59735
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750802AbZCZECH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Mar 2009 00:02:07 -0400
In-Reply-To: <20090325205700.1a4a7fd6@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Wed, 25 Mar 2009 20:57:00 -0700

> This fixes an crash when empty bond device is added to a bridge.
> If an interface with invalid ethernet address (all zero) is added
> to a bridge, then bridge code detects it when setting up the forward
> databas entry. But the error unwind is broken, the bridge port object 
> can get freed twice: once when ref count went to zeo, and once by kfree.
> Since object is never really accessible, just free it.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied, thanks.
