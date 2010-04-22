From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: fix outsegs stat for TSO segments
Date: Wed, 21 Apr 2010 22:28:27 -0700 (PDT)
Message-ID: <20100421.222827.15606873.davem@davemloft.net>
References: <alpine.DEB.1.00.1004212214110.14731@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51731
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750720Ab0DVF2X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Apr 2010 01:28:23 -0400
In-Reply-To: <alpine.DEB.1.00.1004212214110.14731@pokey.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <therbert@google.com>
Date: Wed, 21 Apr 2010 22:17:24 -0700 (PDT)

>  	if (after(tcb->end_seq, tp->snd_nxt) || tcb->seq == tcb->end_seq)
> -		TCP_INC_STATS(sock_net(sk), TCP_MIB_OUTSEGS);
> +		TCP_ADD_STATS(sock_net(sk), TCP_MIB_OUTSEGS,
> +		    tcp_skb_pcount(skb));

Please follow proper coding style and make the new line
with the 'tcp_skb_pcount(skb)' argument line up with
the start of the macro arguments on the previous line.
