From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next-2.6 00/47] vlan cleanup
Date: Thu, 21 Jul 2011 13:57:19 -0700 (PDT)
Message-ID: <20110721.135719.1308347703344986629.davem@davemloft.net>
References: <1311173689-17419-1-git-send-email-jpirko@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@linux-foundation.org,
	eric.dumazet@gmail.com, greearb@candelatech.com, mirqus@gmail.com
To: jpirko@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:54401 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752718Ab1GUU53 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jul 2011 16:57:29 -0400
In-Reply-To: <1311173689-17419-1-git-send-email-jpirko@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jpirko@redhat.com>
Date: Wed, 20 Jul 2011 16:54:02 +0200

> This patchset converts several drivers to new vlan model.
> Also kills several vlan helpers:
> lro_vlan_hwaccel_receive_skb
> lro_vlan_hwaccel_receive_frags
> __vlan_hwaccel_rx
> vlan_hwaccel_rx
> vlan_hwaccel_receive_skb
> vlan_gro_frags
> vlan_gro_receive
> 
> Removes ndo_vlan_rx_register
> 
> note gianfar patch is dependent on "[PATCH] gianfar: rx parser"

Ok, I applied the latest version of all of the patches (except the
'rx parser' one of course :-), after merging net-2.6 into net-next-2.6

Thanks!
