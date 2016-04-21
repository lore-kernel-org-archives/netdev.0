From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv3 net-next] net: use jiffies_to_msecs to replace
 EXPIRES_IN_MS in inet/sctp_diag
Date: Thu, 21 Apr 2016 13:56:13 -0400 (EDT)
Message-ID: <20160421.135613.237170463938906762.davem@davemloft.net>
References: <87a0e83132ce64a3fe2266a5323fa6577a2e5c96.1461049801.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
	marcelo.leitner@gmail.com, vyasevich@gmail.com,
	daniel@iogearbox.net, eric.dumazet@gmail.com, jsitnick@redhat.com
To: lucien.xin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54063 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753671AbcDUR4P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Apr 2016 13:56:15 -0400
In-Reply-To: <87a0e83132ce64a3fe2266a5323fa6577a2e5c96.1461049801.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Xin Long <lucien.xin@gmail.com>
Date: Tue, 19 Apr 2016 15:10:01 +0800

> EXPIRES_IN_MS macro comes from net/ipv4/inet_diag.c and dates
> back to before jiffies_to_msecs() has been introduced.
> 
> Now we can remove it and use jiffies_to_msecs().
> 
> Signed-off-by: Xin Long <lucien.xin@gmail.com>

Applied, thanks.
