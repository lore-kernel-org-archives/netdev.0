From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 1/2] net-timestamp: fix missing ACK timestamp
Date: Tue, 12 Aug 2014 15:16:25 -0700 (PDT)
Message-ID: <20140812.151625.928342154282151683.davem@davemloft.net>
References: <1407869597-9583-1-git-send-email-willemb@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
	richardcochran@gmail.com
To: willemb@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39551 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753537AbaHLWQ0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Aug 2014 18:16:26 -0400
In-Reply-To: <1407869597-9583-1-git-send-email-willemb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>
Date: Tue, 12 Aug 2014 14:53:16 -0400

> ACK timestamps are generated in tcp_clean_rtx_queue. The TSO datapath
> can break out early, causing the timestamp code to be skipped. Move
> the code up before the break.
> 
> Reported-by: David S. Miller <davem@davemloft.net>
> 
> Also fix a boundary condition: tp->snd_una is the next unacknowledged
> byte and between tests inclusive (a <= b <= c), so generate a an ACK
> timestamp if (prior_snd_una <= tskey <= tp->snd_una - 1).
> 
> Signed-off-by: Willem de Bruijn <willemb@google.com>

Applied.
