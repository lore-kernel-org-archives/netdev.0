From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH][VLAN]: Proc entry is not renamed when vlan device name
 changes.
Date: Tue, 01 Apr 2008 08:53:12 +0200
Message-ID: <47F1DBD8.9080603@trash.net>
References: <47F0E1C7.7040908@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org
To: Pavel Emelyanov <xemul@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:50109 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751703AbYDAGxR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Apr 2008 02:53:17 -0400
In-Reply-To: <47F0E1C7.7040908@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pavel Emelyanov wrote:
> This may lead to situations, when each of two proc entries produce
> data for the other's device.
> 
> Looks like a BUG, so this patch is for net-2.6. It will not apply 
> to net-2.6.26 since dev->nd_net access is replaced with dev_net(dev) 
> one. Should I rework the patch to fit 2.6.26?

No, since its a bugfix it should go in net-2.6. Dave, please apply.
