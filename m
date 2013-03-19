From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 1/4] tcp: fix too short FIN_WAIT2 time out
Date: Tue, 19 Mar 2013 09:32:57 -0400 (EDT)
Message-ID: <20130319.093257.1744500513624729643.davem@davemloft.net>
References: <1363610163.7121.2.camel@ubuntu-vm-makita>
	<1363610344.7121.5.camel@ubuntu-vm-makita>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: makita.toshiaki@lab.ntt.co.jp
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42529 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751860Ab3CSNdA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Mar 2013 09:33:00 -0400
In-Reply-To: <1363610344.7121.5.camel@ubuntu-vm-makita>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Date: Mon, 18 Mar 2013 21:39:04 +0900

>  		if (tp->linger2 >= 0) {
> -			const int tmo = tcp_fin_time(sk) - TCP_TIMEWAIT_LEN;
> -
> -			if (tmo > 0) {
> -				tcp_time_wait(sk, TCP_FIN_WAIT2, tmo);
> -				goto out;
> -			}
> +			tcp_time_wait(sk, TCP_FIN_WAIT2, TCP_TIMEWAIT_LEN);
> +			goto out;
>  		}

Well, now you're completely ignoring the user's linger setting.

I really can't take these patches seriously, and will not apply them,
sorry.
