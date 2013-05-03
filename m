From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] gre: Fix GREv4 TCPv6 segmentation.
Date: Fri, 03 May 2013 16:11:49 -0400 (EDT)
Message-ID: <20130503.161149.1251743328601859737.davem@davemloft.net>
References: <1367547259-17919-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sesse@google.com, eric.dumazet@gmail.com
To: pshelar@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48129 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933831Ab3ECULv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 May 2013 16:11:51 -0400
In-Reply-To: <1367547259-17919-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pravin B Shelar <pshelar@nicira.com>
Date: Thu,  2 May 2013 19:14:19 -0700

> For ipv6 traffic, GRE can generate packet with strange GSO
> bits, e.g. ipv4 packet with SKB_GSO_TCPV6 flag set.  Therefore
> following patch relaxes check in inet gso handler to allow
> such packet for segmentation.
> This patch also fixes wrong skb->protocol set that was done in
> gre_gso_segment() handler.
> 
> Reported-by: Steinar H. Gunderson <sesse@google.com>
> CC: Eric Dumazet <eric.dumazet@gmail.com>
> Signed-off-by: Pravin B Shelar <pshelar@nicira.com>

Applied.
