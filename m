From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH][VLAN] Merge tree equal tails in vlan_skb_recv
Date: Fri, 07 Dec 2007 11:25:35 +0100
Message-ID: <47591F9F.1020607@trash.net>
References: <47591ECF.2020707@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org
To: Pavel Emelyanov <xemul@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:59194 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751223AbXLGK0R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Dec 2007 05:26:17 -0500
In-Reply-To: <47591ECF.2020707@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pavel Emelyanov wrote:
> There are tree paths in it, that set the skb->proto and then
> perform common receive manipulations (basically call netif_rx()).
> 
> I think, that we can make this code flow easier to understand
> by introducing the vlan_set_encap_proto() function (I hope the 
> name is good) to setup the skb proto and merge the paths calling 
> netif_rx() together.
> 
> Surprisingly, but gcc detects this thing and merges these paths
> by itself, so this patch doesn't make the vlan module smaller.


I already have something similar queued, but your patch is a nice
cleanup on top. I'll merge it into my tree and send it out after
some testing, hopefully today.
