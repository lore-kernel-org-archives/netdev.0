From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][VLAN]: Fix egress priority mappings leak.
Date: Fri, 04 Apr 2008 12:45:50 -0700 (PDT)
Message-ID: <20080404.124550.02803879.davem@davemloft.net>
References: <47F5FDD7.1060608@openvz.org>
	<47F5F8D6.1050204@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xemul@openvz.org, netdev@vger.kernel.org, devel@openvz.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41741
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756072AbYDDTpt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Apr 2008 15:45:49 -0400
In-Reply-To: <47F5F8D6.1050204@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>
Date: Fri, 04 Apr 2008 11:45:58 +0200

> Pavel Emelyanov wrote:
> > These entries are allocated in vlan_dev_set_egress_priority, 
> > but are never released and leaks on vlan device removal.
> > 
> > Drop these in vlan's ->uninit callback - after the device is 
> > brought down and everyone is notified about it is going to
> > be unregistered.
> > 
> > Found during testing vlan netnsization patchset.
> > 
> > Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
> 
> Good catch, thanks.
> 
> Acked-by: Patrick McHardy <kaber@trash.net>

Applied, thanks a lot.
