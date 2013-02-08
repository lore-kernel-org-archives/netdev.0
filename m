From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: sctp: sctp_auth_make_key_vector: remove
 duplicate ntohs calls
Date: Thu, 07 Feb 2013 23:45:20 -0500 (EST)
Message-ID: <20130207.234520.1493484945207262693.davem@davemloft.net>
References: <cover.1360237025.git.dborkman@redhat.com>
	<c029f55f4d0bde790f77f62d623f4d1e387c4c0b.1360237025.git.dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vyasevich@gmail.com, linux-sctp@vger.kernel.org,
	netdev@vger.kernel.org
To: dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56767 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759902Ab3BHEpW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Feb 2013 23:45:22 -0500
In-Reply-To: <c029f55f4d0bde790f77f62d623f4d1e387c4c0b.1360237025.git.dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>
Date: Thu,  7 Feb 2013 12:41:39 +0100

> Instead of calling 3 times ntohs(random->param_hdr.length), 2 times
> ntohs(hmacs->param_hdr.length), and 3 times ntohs(chunks->param_hdr.length)
> within the same function, we only call each once and store it in a
> variable.
> 
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>

Applied.
