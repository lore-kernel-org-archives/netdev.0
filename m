From: David Miller <davem@davemloft.net>
Subject: Re: [RFC v2] tcp: Export TCP Delayed ACK parameters to user
Date: Fri, 28 Oct 2011 17:19:04 -0400 (EDT)
Message-ID: <20111028.171904.1635229691857703124.davem@davemloft.net>
References: <1319756841-2051-1-git-send-email-dbaluta@ixiacom.com>
	<1319836443-4419-1-git-send-email-dbaluta@ixiacom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, netdev@vger.kernel.org,
	luto@amacapital.net, rick.jones2@hp.com
To: dbaluta@ixiacom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:39003 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933393Ab1J1VWM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Oct 2011 17:22:12 -0400
In-Reply-To: <1319836443-4419-1-git-send-email-dbaluta@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Baluta <dbaluta@ixiacom.com>
Date: Sat, 29 Oct 2011 00:14:03 +0300

> +static inline int tcp_delack_thresh(const struct sock *sk)
> +{
> +	return inet_csk(sk)->icsk_ack.rcv_mss * sysctl_tcp_delack_segs;
> +}
> +

Please turn this into a shift or something, you're adding a multiply
into a core code path.
