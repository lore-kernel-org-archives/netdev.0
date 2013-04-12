From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] sctp: Add buffer utilization fields to
 /proc/net/sctp/assocs
Date: Fri, 12 Apr 2013 19:28:00 -0400 (EDT)
Message-ID: <20130412.192800.2206884577519855725.davem@davemloft.net>
References: <1365808931.6961.14.camel@pro6455b.example.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
	nhorman@tuxdriver.com, dborkman@redhat.com
To: dilip.daya@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55161 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753371Ab3DLX2B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Apr 2013 19:28:01 -0400
In-Reply-To: <1365808931.6961.14.camel@pro6455b.example.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dilip Daya <dilip.daya@hp.com>
Date: Fri, 12 Apr 2013 19:22:11 -0400

> From: Dilip Daya <dilip.daya@hp.com>
> 
> This patch adds the following fields to /proc/net/sctp/assocs output:
> 
> 	- sk->sk_wmem_alloc as "wmema"	(transmit queue bytes committed)
> 	- sk->sk_wmem_queued as "wmemq"	(persistent queue size)
> 	- sk->sk_sndbuf as "sndbuf"	(size of send buffer in bytes)
> 	- sk->sk_rcvbuf as "rcvbuf"	(size of receive buffer in bytes)
 ...
> Signed-off-by: Dilip Daya <dilip.daya@hp.com>
> Acked-by: Neil Horman <nhorman@tuxdriver.com>

Looks good, applied, thanks.
