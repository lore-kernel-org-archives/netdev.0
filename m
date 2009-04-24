From: Patrick McHardy <kaber@trash.net>
Subject: Re: more findings/questions on vlans/bonds
Date: Fri, 24 Apr 2009 17:22:54 +0200
Message-ID: <49F1D94E.6080601@trash.net>
References: <Pine.LNX.4.64.0904071202110.14639@zuben.voltaire.com> <13724.1240520690@death.nxdomain.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Or Gerlitz <ogerlitz@voltaire.com>, netdev@vger.kernel.org
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:47503 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755131AbZDXPXD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Apr 2009 11:23:03 -0400
In-Reply-To: <13724.1240520690@death.nxdomain.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jay Vosburgh wrote:
> [PATCH] vlan: update vlan carrier state for admin up/down
> 
> 	Currently, the VLAN event handler does not adjust the VLAN
> device's carrier state when the real device or the VLAN device is set
> administratively up or down.
> 
> 	The following patch adds a transfer of operating state from the
> real device to the VLAN device when the real device is administratively
> set up or down, and sets the carrier state up or down during init, open
> and close of the VLAN device.
> 
> 	This permits observers above the VLAN device that care about the
> carrier state (bonding's link monitor, for example) to receive updates
> for administrative changes by more closely mimicing the behavior of real
> devices.

Looks good, applied, thanks Jay.
