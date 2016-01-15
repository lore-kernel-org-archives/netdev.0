From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] sctp: support to lookup with ep+paddr in transport
 rhashtable
Date: Fri, 15 Jan 2016 14:45:56 -0500 (EST)
Message-ID: <20160115.144556.655392601284850128.davem@davemloft.net>
References: <66cb37a6d0c3776e9eb3adf0bf6fc33ff947eb63.1452750574.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
	marcelo.leitner@gmail.com, vyasevich@gmail.com,
	daniel@iogearbox.net
To: lucien.xin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:32811 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751361AbcAOTp5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jan 2016 14:45:57 -0500
In-Reply-To: <66cb37a6d0c3776e9eb3adf0bf6fc33ff947eb63.1452750574.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Xin Long <lucien.xin@gmail.com>
Date: Thu, 14 Jan 2016 13:49:34 +0800

> Now, when we sendmsg, we translate the ep to laddr by selecting the
> first element of the list, and then do a lookup for a transport.
> 
> But sctp_hash_cmp() will compare it against asoc addr_list, which may
> be a subset of ep addr_list, meaning that this chosen laddr may not be
> there, and thus making it impossible to find the transport.
> 
> So we fix it by using ep + paddr to lookup transports in hashtable. In
> sctp_hash_cmp, if .ep is set, we will check if this ep == asoc->ep,
> or we will do the laddr check.
> 
> Fixes: d6c0256a60e6 ("sctp: add the rhashtable apis for sctp global transport hashtable")
> Signed-off-by: Xin Long <lucien.xin@gmail.com>
> Acked-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
> Reported-by: Vlad Yasevich <vyasevich@gmail.com>

Applied, thanks.
