From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/4 net-next] tcp: refactor undo functions
Date: Thu, 30 May 2013 18:07:22 -0700 (PDT)
Message-ID: <20130530.180722.393027289131894498.davem@davemloft.net>
References: <1369873214-29502-1-git-send-email-ycheng@google.com>
	<1369873214-29502-2-git-send-email-ycheng@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ncardwell@google.com, edumazet@google.com, nanditad@google.com,
	aterzis@google.com, netdev@vger.kernel.org
To: ycheng@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59807 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751999Ab3EaBHX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 May 2013 21:07:23 -0400
In-Reply-To: <1369873214-29502-2-git-send-email-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuchung Cheng <ycheng@google.com>
Date: Wed, 29 May 2013 17:20:12 -0700

> Refactor and relocate various functions or variables to prepare the
> undo fix.  Remove some unused function arguments. Rename tcp_undo_cwr
> to tcp_undo_cwnd_reduction to be consistent with the rest of
> CWR related function names.
> 
> Signed-off-by: Yuchung Cheng <ycheng@google.com>

Applied, but:

> -static void tcp_undo_cwr(struct sock *sk, const bool undo_ssthresh)
> +static void tcp_undo_cwnd_reduction(struct sock *sk, const bool undo_ssthresh,
> +				    bool unmark_loss)

Both bool arguments seem const to me.  Please audit the rest of the
functions you changed and send a cleanup patch to consistently use
const wherever possible.

Thanks.
