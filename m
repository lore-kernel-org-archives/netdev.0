From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] sctp: the temp asoc's transports should not be
 hashed/unhashed
Date: Sun, 17 Jan 2016 19:12:20 -0500 (EST)
Message-ID: <20160117.191220.636907487411695644.davem@davemloft.net>
References: <488453d4e06805934290a1ef3cf633ee4b26bdc6.1452946637.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
	marcelo.leitner@gmail.com, vyasevich@gmail.com,
	daniel@iogearbox.net
To: lucien.xin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33555 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752117AbcARAMW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Jan 2016 19:12:22 -0500
In-Reply-To: <488453d4e06805934290a1ef3cf633ee4b26bdc6.1452946637.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Xin Long <lucien.xin@gmail.com>
Date: Sat, 16 Jan 2016 20:17:17 +0800

> Re-establish the previous behavior and avoid hashing temporary asocs by
> checking t->asoc->temp in sctp_(un)hash_transport. Also, remove the
> check of t->asoc->temp in __sctp_lookup_association, since they are
> never hashed now.
> 
> Fixes: 4f0087812648 ("sctp: apply rhashtable api to send/recv path")
> Signed-off-by: Xin Long <lucien.xin@gmail.com>
> Acked-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
> Reported-by: Vlad Yasevich <vyasevich@gmail.com>

Applied, thanks.
