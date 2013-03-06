From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] htb: add HTB_DIRECT_QLEN attribute
Date: Wed, 06 Mar 2013 15:42:19 -0500 (EST)
Message-ID: <20130306.154219.785938154338664549.davem@davemloft.net>
References: <1362588561.15793.178.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jhs@mojatatu.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59302 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753539Ab3CFUmV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Mar 2013 15:42:21 -0500
In-Reply-To: <1362588561.15793.178.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 06 Mar 2013 08:49:21 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> HTB uses an internal pfifo queue, which limit is not reported
> to userland tools (tc), and value inherited from device tx_queue_len
> at setup time.
> 
> Introduce TCA_HTB_DIRECT_QLEN attribute to allow finer control.
> 
> Remove two obsolete pr_err() calls as well.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Jamal Hadi Salim <jhs@mojatatu.com>

Applied.
