From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH v7 4/7 RFC] TCPCT part 1d: define TCP
 cookie option, extend existing struct's
Date: Fri, 20 Nov 2009 09:25:15 -0800 (PST)
Message-ID: <20091120.092515.126988512.davem@davemloft.net>
References: <4B06A1FF.8000202@gmail.com>
	<4B06A9D4.8070007@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: william.allen.simpson@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33041
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753484AbZKTRY6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Nov 2009 12:24:58 -0500
In-Reply-To: <4B06A9D4.8070007@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: William Allen Simpson <william.allen.simpson@gmail.com>
Date: Fri, 20 Nov 2009 09:38:12 -0500

>  static inline void tcp_clear_options(struct tcp_options_received *rx_opt)
>  {
> -	rx_opt->tstamp_ok = rx_opt->sack_ok = rx_opt->wscale_ok = rx_opt->snd_wscale = 0;
> +	rx_opt->tstamp_ok = rx_opt->sack_ok = 0;
> +	rx_opt->wscale_ok = rx_opt->snd_wscale = 0;
> +	rx_opt->cookie_plus = 0;
>  }
>  

Why not get the coding style correct wrt. long lines in patch #3 where
you initially added this function, rather than fixing it here as you
add the new ->cookie_plus assignment?
