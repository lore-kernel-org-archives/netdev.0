From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 1/2] tcp: Remove another indentation level in
 tcp_rcv_state_process
Date: Fri, 24 May 2013 21:24:58 -0700
Message-ID: <1369455898.3301.466.camel@edumazet-glaptop>
References: <1366341367.3205.85.camel@edumazet-glaptop>
	 <1369324525.3301.384.camel@edumazet-glaptop>
	 <1369443834.3301.464.camel@edumazet-glaptop>
	 <1369454556.2080.4.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Yuchung Cheng <ycheng@google.com>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:61382 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750747Ab3EYEZB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 May 2013 00:25:01 -0400
Received: by mail-pa0-f46.google.com with SMTP id fa10so4980816pad.5
        for <netdev@vger.kernel.org>; Fri, 24 May 2013 21:25:00 -0700 (PDT)
In-Reply-To: <1369454556.2080.4.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-05-24 at 21:02 -0700, Joe Perches wrote:
> case TCP_SYN_RECV: can have an indentation level removed
> by converting:
> 
> 	if (acceptable) {
> 		[...];
> 	} else {
> 		return 1;
> 	}
> 
> to
> 	if (!acceptable)
> 		return 1;
> 	[...];
> 
> Reflow comments to fit 80 columns.
> 
> A neatening only patch.
> 
> Signed-off-by: Joe Perches <joe@perches.com>
> ---

> +		tp->snd_wnd = ntohs(th->window) <<
> +			tp->rx_opt.snd_wscale;

single line ?
