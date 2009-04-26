From: David Miller <davem@davemloft.net>
Subject: Re: vlan: update vlan carrier state for admin up/down
Date: Sat, 25 Apr 2009 18:06:28 -0700 (PDT)
Message-ID: <20090425.180628.109371724.davem@davemloft.net>
References: <49F1DE6F.1030606@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33882
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751425AbZDZBGe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Apr 2009 21:06:34 -0400
In-Reply-To: <49F1DE6F.1030606@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>
Date: Fri, 24 Apr 2009 17:44:47 +0200

>     vlan: update vlan carrier state for admin up/down
>     
>     	Currently, the VLAN event handler does not adjust the VLAN
>     device's carrier state when the real device or the VLAN device is set
>     administratively up or down.
>     
>     	The following patch adds a transfer of operating state from the
>     real device to the VLAN device when the real device is administratively
>     set up or down, and sets the carrier state up or down during init, open
>     and close of the VLAN device.
>     
>     	This permits observers above the VLAN device that care about the
>     carrier state (bonding's link monitor, for example) to receive updates
>     for administrative changes by more closely mimicing the behavior of real
>     devices.
>     
>     Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>
>     Signed-off-by: Patrick McHardy <kaber@trash.net>

I've applied this to net-2.6, thanks!

I realize there are some more issues to deal with wrt. the
comments Ben made.  And I eagerly await patches for that :)
