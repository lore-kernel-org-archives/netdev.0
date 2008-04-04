From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH][VLAN]: Fix egress priority mappings leak.
Date: Fri, 04 Apr 2008 11:45:58 +0200
Message-ID: <47F5F8D6.1050204@trash.net>
References: <47F5FDD7.1060608@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org
To: Pavel Emelyanov <xemul@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:64380 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750973AbYDDJp7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Apr 2008 05:45:59 -0400
In-Reply-To: <47F5FDD7.1060608@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pavel Emelyanov wrote:
> These entries are allocated in vlan_dev_set_egress_priority, 
> but are never released and leaks on vlan device removal.
> 
> Drop these in vlan's ->uninit callback - after the device is 
> brought down and everyone is notified about it is going to
> be unregistered.
> 
> Found during testing vlan netnsization patchset.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Good catch, thanks.

Acked-by: Patrick McHardy <kaber@trash.net>
