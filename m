From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] sctp: change sk state to CLOSED instead of
 CLOSING in sctp_sock_migrate
Date: Thu, 16 Jun 2016 14:11:39 -0700 (PDT)
Message-ID: <20160616.141139.1258089118185183298.davem@davemloft.net>
References: <9229f8aa0f4324831fc31b5334cde9a258404b62.1466010906.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
	marcelo.leitner@gmail.com, vyasevich@gmail.com,
	daniel@iogearbox.net, xiaolong.ye@intel.com, eric.dumazet@gmail.com
To: lucien.xin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43154 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754006AbcFPVLk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jun 2016 17:11:40 -0400
In-Reply-To: <9229f8aa0f4324831fc31b5334cde9a258404b62.1466010906.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Xin Long <lucien.xin@gmail.com>
Date: Thu, 16 Jun 2016 01:15:06 +0800

> Commit d46e416c11c8 ("sctp: sctp should change socket state when
> shutdown is received") may set sk_state CLOSING in sctp_sock_migrate,
> but inet_accept doesn't allow the sk_state other than ESTABLISHED/
> CLOSED for sctp. So we will change sk_state to CLOSED, instead of
> CLOSING, as actually sk is closed already there.
> 
> Fixes: commit d46e416c11c8 ("sctp: sctp should change socket state when shutdown is received")
> Reported-by: Ye Xiaolong <xiaolong.ye@intel.com>
> Signed-off-by: Xin Long <lucien.xin@gmail.com>

Applied.
