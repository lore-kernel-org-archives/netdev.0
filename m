From: David Miller <davem@davemloft.net>
Subject: Re: [GIT net-next] Open vSwitch
Date: Fri, 30 Nov 2012 12:03:27 -0500 (EST)
Message-ID: <20121130.120327.2127690814376752338.davem@davemloft.net>
References: <1354214149-33651-1-git-send-email-jesse@nicira.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dev@openvswitch.org
To: jesse@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44443 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1031196Ab2K3RD3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Nov 2012 12:03:29 -0500
In-Reply-To: <1354214149-33651-1-git-send-email-jesse@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Gross <jesse@nicira.com>
Date: Thu, 29 Nov 2012 10:35:42 -0800

> This series of improvements for 3.8/net-next contains four components:
>  * Support for modifying IPv6 headers
>  * Support for matching and setting skb->mark for better integration with
>    things like iptables
>  * Ability to recognize the EtherType for RARP packets
>  * Two small performance enhancements
> 
> The movement of ipv6_find_hdr() into exthdrs_core.c causes two small merge
> conflicts.  I left it as is but can do the merge if you want.  The conflicts
> are:
>  * ipv6_find_hdr() and ipv6_find_tlv() were both moved to the bottom of
>    exthdrs_core.c.  Both should stay.
>  * A new use of ipv6_find_hdr() was added to net/netfilter/ipvs/ip_vs_core.c
>    after this patch.  The IPVS user has two instances of the old constant
>    name IP6T_FH_F_FRAG which has been renamed to IP6_FH_F_FRAG.

Pulled, thanks Jesse.

The merge conflict directions were particularly helpful.

If you ever do the merge yourself (I'm ambivalent about where you or I
do it), make sure you force the merge commit message to have a
description of the conflict resolution similarly to what you provided
here.

Thanks again.
