From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4] sctp: Add buffer utilization fields to
 /proc/net/sctp/assocs
Date: Tue, 16 Apr 2013 16:40:19 -0400 (EDT)
Message-ID: <20130416.164019.1074985550251974378.davem@davemloft.net>
References: <1366112347.7478.10.camel@pro6455b.example.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
	nhorman@tuxdriver.com, dborkman@redhat.com
To: dilip.daya@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49805 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965211Ab3DPUkW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Apr 2013 16:40:22 -0400
In-Reply-To: <1366112347.7478.10.camel@pro6455b.example.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dilip Daya <dilip.daya@hp.com>
Date: Tue, 16 Apr 2013 07:39:07 -0400

> From: Dilip Daya <dilip.daya@hp.com>
> 
> sctp: Add buffer utilization fields to /proc/net/sctp/assocs
> 
> This patch adds the following fields to /proc/net/sctp/assocs output:
> 
> 	- sk->sk_wmem_alloc as "wmema"	(transmit queue bytes committed)
> 	- sk->sk_wmem_queued as "wmemq"	(persistent queue size)
> 	- sk->sk_sndbuf as "sndbuf"	(size of send buffer in bytes)
> 	- sk->sk_rcvbuf as "rcvbuf"	(size of receive buffer in bytes)
> 
> When small DATA chunks containing 136 bytes data are sent the TX_QUEUE
> (assoc->sndbuf_used) reaches a maximum of 40.9% of sk_sndbuf value when
> peer.rwnd = 0. This was diagnosed from sk_wmem_alloc value reaching maximum
> value of sk_sndbuf.
> 
> TX_QUEUE (assoc->sndbuf_used), sk_wmem_alloc and sk_wmem_queued values are
> incremented in sctp_set_owner_w() for outgoing data chunks. Having access to
> the above values in /proc/net/sctp/assocs will provide a better understanding
> of SCTP buffer management.
 ...
> Signed-off-by: Dilip Daya <dilip.daya@hp.com>
> Acked-by: Neil Horman <nhorman@tuxdriver.com>

Applied.
