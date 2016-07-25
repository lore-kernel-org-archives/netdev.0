From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] sctp: use inet_recvmsg to support sctp RFS
 well
Date: Mon, 25 Jul 2016 10:56:46 -0700 (PDT)
Message-ID: <20160725.105646.945632034160752030.davem@davemloft.net>
References: <75f49fcd6f30e7ec41dc0f8e39983a9579386e49.1469193942.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
	marcelo.leitner@gmail.com, vyasevich@gmail.com,
	daniel@iogearbox.net
To: lucien.xin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:43262 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753456AbcGYR4r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jul 2016 13:56:47 -0400
In-Reply-To: <75f49fcd6f30e7ec41dc0f8e39983a9579386e49.1469193942.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Xin Long <lucien.xin@gmail.com>
Date: Fri, 22 Jul 2016 21:25:42 +0800

> Commit 486bdee0134c ("sctp: add support for RPS and RFS")
> saves skb->hash into sk->sk_rxhash so that the inet_* can
> record it to flow table.
> 
> But sctp uses sock_common_recvmsg as .recvmsg instead
> of inet_recvmsg, sock_common_recvmsg doesn't invoke
> sock_rps_record_flow to record the flow. It may cause
> that the receiver has no chances to record the flow if
> it doesn't send msg or poll the socket.
> 
> So this patch fixes it by using inet_recvmsg as .recvmsg
> in sctp.
> 
> Fixes: 486bdee0134c ("sctp: add support for RPS and RFS")
> Signed-off-by: Xin Long <lucien.xin@gmail.com>

Applied.
