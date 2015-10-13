From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/4 v3] net: VRF support in IPv6 stack
Date: Tue, 13 Oct 2015 04:56:28 -0700 (PDT)
Message-ID: <20151013.045628.1427505591915527875.davem@davemloft.net>
References: <1444675630-42959-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47619 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751930AbbJMLk1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Oct 2015 07:40:27 -0400
In-Reply-To: <1444675630-42959-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Mon, 12 Oct 2015 11:47:06 -0700

> Initial support for VRF in IPv6 stack. Makes IPv6 functionality on par
> with IPv4 -- ping, tcp client/server and udp client/server all work fine.
> tcpdump on vrf device and external tap (e.g., host side tap device) shows
> all packets with proper addresses. IPv6 does not need the source address
> operation like IPv4. Verified vti6 works properly in my setup as does use
> of an IPv6 address on the VRF device.
> 
> v3
> - re-based to top of net-next (updates per net namespace changes by Eric)
> - fixed dst_entry typecasts as requested by Dave
> - added flags to inet6_rtm_getroute (IPv6 version of deaa0a6a930e)
> 
> v2
> - fixed CONFIG_IPV6 dependency as questioned by Cong
>   - if IPV6 is a module, kbuild ensures VRF is a module
>   - if IPV6 is disabled IPV6 functionality is compiled out of VRF module
> - addressed comments from Nik over IRC
>   - removed duplicate call to netif_is_l3_master in l3mdev_rt6_dst_by_oif
>   - changed allocation flag from GFP_ATOMIC to GFP_KERNEL since it is init time
>   - added free of rt6i_pcpu
>   - check_ipv6_frame returns false only if packet is NDISC type

Series applied, thanks.
