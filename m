From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] sctp: allow receiving msg when TCP-style sk is in
 CLOSED state
Date: Sat, 30 Jul 2016 22:07:10 -0700 (PDT)
Message-ID: <20160730.220710.6804773780755703.davem@davemloft.net>
References: <d108342f2f89cfdf7f9abc529a746a032e236b78.1469859281.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
	marcelo.leitner@gmail.com, vyasevich@gmail.com,
	daniel@iogearbox.net
To: lucien.xin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:51898 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750885AbcGaFHM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 31 Jul 2016 01:07:12 -0400
In-Reply-To: <d108342f2f89cfdf7f9abc529a746a032e236b78.1469859281.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Xin Long <lucien.xin@gmail.com>
Date: Sat, 30 Jul 2016 14:14:41 +0800

> Commit 141ddefce7c8 ("sctp: change sk state to CLOSED instead of
> CLOSING in sctp_sock_migrate") changed sk state to CLOSED if the
> assoc is closed when sctp_accept clones a new sk.
> 
> If there is still data in sk receive queue, users will not be able
> to read it any more, as sctp_recvmsg returns directly if sk state
> is CLOSED.
> 
> This patch is to add CLOSED state check in sctp_recvmsg to allow
> reading data from TCP-style sk with CLOSED state as what TCP does.
> 
> Signed-off-by: Xin Long <lucien.xin@gmail.com>

Applied.
