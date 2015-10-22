From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] openvswitch: Fix incorrect type use.
Date: Thu, 22 Oct 2015 06:46:42 -0700 (PDT)
Message-ID: <20151022.064642.782712229052859611.davem@davemloft.net>
References: <1445399266-2034-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: pshelar@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54046 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755988AbbJVNaP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Oct 2015 09:30:15 -0400
In-Reply-To: <1445399266-2034-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pravin B Shelar <pshelar@nicira.com>
Date: Tue, 20 Oct 2015 20:47:46 -0700

> Patch fixes following sparse warning.
> net/openvswitch/flow_netlink.c:583:30: warning: incorrect type in assignment (different base types)
> net/openvswitch/flow_netlink.c:583:30:    expected restricted __be16 [usertype] ipv4
> net/openvswitch/flow_netlink.c:583:30:    got int
> 
> Fixes: 6b26ba3a7d ("openvswitch: netlink attributes for IPv6 tunneling")
> Signed-off-by: Pravin B Shelar <pshelar@nicira.com>

Applied.
