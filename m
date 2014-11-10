From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net] udptunnel: Add SKB_GSO_UDP_TUNNEL during
 gro_complete.
Date: Mon, 10 Nov 2014 15:11:43 -0500 (EST)
Message-ID: <20141110.151143.633771685225951598.davem@davemloft.net>
References: <1415648713-110483-1-git-send-email-jesse@nicira.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jesse@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47886 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751431AbaKJULp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Nov 2014 15:11:45 -0500
In-Reply-To: <1415648713-110483-1-git-send-email-jesse@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Gross <jesse@nicira.com>
Date: Mon, 10 Nov 2014 11:45:13 -0800

> When doing GRO processing for UDP tunnels, we never add
> SKB_GSO_UDP_TUNNEL to gso_type - only the type of the inner protocol
> is added (such as SKB_GSO_TCPV4). The result is that if the packet is
> later resegmented we will do GSO but not treat it as a tunnel. This
> results in UDP fragmentation of the outer header instead of (i.e.) TCP
> segmentation of the inner header as was originally on the wire.
> 
> Signed-off-by: Jesse Gross <jesse@nicira.com>
> ---
> v2: Update commit message to reflect result of problem.

Applied, thanks.
