From: David Miller <davem@davemloft.net>
Subject: Re: [VLAN 02/04]: Fix MAC address handling
Date: Wed, 11 Jul 2007 19:41:58 -0700 (PDT)
Message-ID: <20070711.194158.131104856.davem@davemloft.net>
References: <20070711173812.18369.47109.sendpatchset@localhost.localdomain>
	<20070711173815.18369.24201.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, greearb@candelatech.com, xemul@openvz.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41637
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756665AbXGLCle (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jul 2007 22:41:34 -0400
In-Reply-To: <20070711173815.18369.24201.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>
Date: Wed, 11 Jul 2007 19:38:16 +0200 (MEST)

> [VLAN]: Fix MAC address handling
> 
> The VLAN MAC address handling is broken in multiple ways. When the address
> differs when setting it, the real device is put in promiscous mode twice,
> but never taken out again. Additionally it doesn't resync when the real
> device's address is changed and needlessly puts it in promiscous mode when
> the vlan device is still down.
> 
> Fix by moving address handling to vlan_dev_open/vlan_dev_stop and properly
> deal with address changes in the device notifier. Also switch to
> dev_unicast_add (which needs the exact same handling).
> 
> Since the set_mac_address handler is identical to the generic ethernet one
> with these changes, kill it and use ether_setup().
> 
> Signed-off-by: Patrick McHardy <kaber@trash.net>

Applied, thanks.
