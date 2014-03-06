From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: sctp: fix skb leakage in COOKIE ECHO path of
 chunk->auth_chunk
Date: Wed, 05 Mar 2014 20:47:01 -0500 (EST)
Message-ID: <20140305.204701.2006215043535025759.davem@davemloft.net>
References: <1393947351-11664-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
	yasevich@gmail.com, nhorman@tuxdriver.com
To: dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51768 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756397AbaCFBrD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Mar 2014 20:47:03 -0500
In-Reply-To: <1393947351-11664-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>
Date: Tue,  4 Mar 2014 16:35:51 +0100

> While working on ec0223ec48a9 ("net: sctp: fix sctp_sf_do_5_1D_ce to
> verify if we/peer is AUTH capable"), we noticed that there's a skb
> memory leakage in the error path.
 ...
> Fixes: bbd0d59809f9 ("[SCTP]: Implement the receive and verification of AUTH chunk")
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>

Applied and queued up for -stable, thanks.
