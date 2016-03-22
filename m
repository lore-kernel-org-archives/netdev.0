From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net v2] ipv4: fix broadcast packets reception
Date: Tue, 22 Mar 2016 11:27:40 +0100
Message-ID: <56F11E1C.2030100@stressinduktion.org>
References: <c8ad97bbb6f1c9ec8c523209c1203d1982faab6f.1458634653.git.pabeni@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	Shawn Bohrer <sbohrer@rgmadvisors.com>
To: Paolo Abeni <pabeni@redhat.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:42022 "EHLO
	out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756959AbcCVK1o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Mar 2016 06:27:44 -0400
Received: from compute1.internal (compute1.nyi.internal [10.202.2.41])
	by mailout.nyi.internal (Postfix) with ESMTP id 935532094D
	for <netdev@vger.kernel.org>; Tue, 22 Mar 2016 06:27:43 -0400 (EDT)
In-Reply-To: <c8ad97bbb6f1c9ec8c523209c1203d1982faab6f.1458634653.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 22.03.2016 09:19, Paolo Abeni wrote:
> Currently, ingress ipv4 broadcast datagrams are dropped since,
> in udp_v4_early_demux(), ip_check_mc_rcu() is invoked even on
> bcast packets.
>
> This patch addresses the issue, invoking ip_check_mc_rcu()
> only for mcast packets.
>
> Fixes: 6e5403093261 ("ipv4/udp: Verify multicast group is ours in upd_v4_early_demux()")
> Signed-off-by: Paolo Abeni <pabeni@redhat.com>

Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
