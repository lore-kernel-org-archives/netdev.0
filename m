From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next 0/6] vlan: introduce per-device vlan id list
Date: Thu, 08 Dec 2011 19:53:29 -0500 (EST)
Message-ID: <20111208.195329.137066250797993852.davem@davemloft.net>
References: <1323353480-1900-1-git-send-email-jpirko@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
	bhutchings@solarflare.com, shemminger@vyatta.com,
	ebiederm@xmission.com, mirqus@gmail.com, kaber@trash.net,
	greearb@candelatech.com, jesse@nicira.com
To: jpirko@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:35668 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752792Ab1LIAyn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Dec 2011 19:54:43 -0500
In-Reply-To: <1323353480-1900-1-git-send-email-jpirko@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jpirko@redhat.com>
Date: Thu,  8 Dec 2011 15:11:14 +0100

> Many drivers store vlan ids in their private structures.
> They are maintaining the private lists in vlan_add_vid and vlan_kill_vid.
> 
> This patchset creates an infrastructure of storing vlan ids in one place,
> vlan core. Another benefit of this is that it allows to keep track of vlan
> ids needed. For example if eth0 has vlan id 10 on it, then it enters bonding,
> bonding gets added 10 as well, then eth0 leaves bonding. Final step would
> remove vlan id 10 from eth1 vlan filter resulting in potentially unfunction
> vlan device. This patchset fixes this.
> 
> Jiri Pirko (6):
>   vlan: rename vlan_dev_info to vlan_dev_priv
>   net: make vlan ndo_vlan_rx_[add/kill]_vid return error value
>   net: introduce vlan_vid_[add/del] and use them instead of direct
>     [add/kill]_vid ndo calls
>   vlan: introduce vid list with reference counting
>   vlan: introduce functions to do mass addition/deletion of vids by
>     another device
>   team: use vlan_vids_[addr/del]_by_dev

All applied.
