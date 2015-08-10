From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 net-next] iplink: bonding: add support for
 IFLA_BOND_TLB_DYNAMIC_LB
Date: Mon, 10 Aug 2015 11:22:52 -0700
Message-ID: <20150810112252.6cd0886d@urahara>
References: <1438597195-18044-1-git-send-email-razor@blackwall.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: Nikolay Aleksandrov <razor@blackwall.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:33747 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932106AbbHJSWm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Aug 2015 14:22:42 -0400
Received: by pabyb7 with SMTP id yb7so111628654pab.0
        for <netdev@vger.kernel.org>; Mon, 10 Aug 2015 11:22:41 -0700 (PDT)
In-Reply-To: <1438597195-18044-1-git-send-email-razor@blackwall.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon,  3 Aug 2015 12:19:55 +0200
Nikolay Aleksandrov <razor@blackwall.org> wrote:

> From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
> 
> Add support to be able to set and show the value of tlb_dynamic_lb
> (IFLA_BOND_TLB_DYNAMIC_LB).
> Example:
> $ ip -d link show dev bond0 type bond
> 7: bond0: <BROADCAST,MULTICAST,MASTER> mtu 1500 qdisc noop state DOWN
> mode DEFAULT group default
>     link/ether ce:2f:e1:6e:d7:e0 brd ff:ff:ff:ff:ff:ff promiscuity 0
>     bond mode balance-tlb miimon 100 updelay 0 downdelay 0 use_carrier 1
> arp_interval 0 arp_validate none arp_all_targets any primary_reselect
> always fail_over_mac none xmit_hash_policy layer2 resend_igmp 1
> num_grat_arp 1 all_slaves_active 0 min_links 0 lp_interval 1
> packets_per_slave 1 lacp_rate slow ad_select stable tlb_dynamic_lb 1
> addrgenmode eui64
> 
> $ ip -d l set dev bond0 type bond tlb_dynamic_lb 0
> $ ip -d link show dev bond0 type bond
> 7: bond0: <BROADCAST,MULTICAST,MASTER> mtu 1500 qdisc noop state DOWN
> mode DEFAULT group default
>     link/ether ce:2f:e1:6e:d7:e0 brd ff:ff:ff:ff:ff:ff promiscuity 0
>     bond mode balance-tlb miimon 100 updelay 0 downdelay 0 use_carrier 1
> arp_interval 0 arp_validate none arp_all_targets any primary_reselect
> always fail_over_mac none xmit_hash_policy layer2 resend_igmp 1
> num_grat_arp 1 all_slaves_active 0 min_links 0 lp_interval 1
> packets_per_slave 1 lacp_rate slow ad_select stable tlb_dynamic_lb 0
> addrgenmode eui64
> 
> Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

Applied to net-next
