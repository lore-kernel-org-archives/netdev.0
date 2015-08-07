From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] vxlan: combine VXLAN_FLOWBASED into
 VXLAN_COLLECT_METADATA
Date: Fri, 07 Aug 2015 11:46:45 -0700 (PDT)
Message-ID: <20150807.114645.2108374064397756373.davem@davemloft.net>
References: <1438753867-32403-1-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, jesse@nicira.com, pshelar@nicira.com,
	netdev@vger.kernel.org
To: ast@plumgrid.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50247 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1946006AbbHGSqq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Aug 2015 14:46:46 -0400
In-Reply-To: <1438753867-32403-1-git-send-email-ast@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexei Starovoitov <ast@plumgrid.com>
Date: Tue,  4 Aug 2015 22:51:07 -0700

> IFLA_VXLAN_FLOWBASED is useless without IFLA_VXLAN_COLLECT_METADATA,
> so combine them into single IFLA_VXLAN_COLLECT_METADATA flag.
> 'flowbased' doesn't convey real meaning of the vxlan tunnel mode.
> This mode can be used by routing, tc+bpf and ovs.
> Only ovs is strictly flow based, so 'collect metadata' is a better
> name for this tunnel mode.
> 
> Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
> ---
> it's not too late to kill uapi IFLA_VXLAN_FLOWBASED, since it
> was introduced two weeks ago.
> Alternatively we could rename both into vxlan_accept_metadata
> or something else, but imo collect_metadata is ok.

Applied, thanks.
