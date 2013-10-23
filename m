From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: sctp: fix ASCONF to allow non SCTP_ADDR_SRC
 addresses in ipv6
Date: Wed, 23 Oct 2013 16:57:36 -0400 (EDT)
Message-ID: <20131023.165736.804778459722407050.davem@davemloft.net>
References: <1382459696-1732-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
	micchie@sfc.wide.ad.jp
To: dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41021 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751316Ab3JWU5i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Oct 2013 16:57:38 -0400
In-Reply-To: <1382459696-1732-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>
Date: Tue, 22 Oct 2013 18:34:56 +0200

> Commit 8a07eb0a50 ("sctp: Add ASCONF operation on the single-homed host")
> implemented possible use of IPv4 addresses with non SCTP_ADDR_SRC state
> as source address when sending ASCONF (ADD) packets, but IPv6 part for
> that was not implemented in 8a07eb0a50. Therefore, as this is not restricted
> to IPv4-only, fix this up to allow the same for IPv6 addresses in SCTP.
> 
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
> Cc: Michio Honda <micchie@sfc.wide.ad.jp>

Applied, thanks.
