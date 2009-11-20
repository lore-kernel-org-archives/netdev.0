From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH v7 7/7 RFC] TCPCT part 1g: Responder
 Cookie => Initiator
Date: Fri, 20 Nov 2009 09:31:47 -0800 (PST)
Message-ID: <20091120.093147.145901642.davem@davemloft.net>
References: <4B06A1FF.8000202@gmail.com>
	<4B06B080.3000404@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: william.allen.simpson@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37725
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751547AbZKTRba (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Nov 2009 12:31:30 -0500
In-Reply-To: <4B06B080.3000404@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: William Allen Simpson <william.allen.simpson@gmail.com>
Date: Fri, 20 Nov 2009 10:06:40 -0500

>  	/* RFC1323: H1. Apply PAWS check first. */
> -	if (tcp_fast_parse_options(skb, th, tp) && tp->rx_opt.saw_tstamp &&
> -	    tcp_paws_discard(sk, skb)) {
> +	if (tcp_fast_parse_options(skb, th, tp, &hash_location)
> +	 && tp->rx_opt.saw_tstamp
> +	 && tcp_paws_discard(sk, skb)) {

Please fix this conditional's coding style.  The '&&' belongs at
the end of the previous line not at the beginning of the next
one.  Also the indentation is not correct.

> +
> +		if (cvp != NULL
> +		 && cvp->cookie_pair_size > 0
> +		 && tp->rx_opt.cookie_plus > 0) {

Likewise.

> +	if (tmp_opt.cookie_plus > 0
> +	 && tmp_opt.saw_tstamp
> +	 && !tp->rx_opt.cookie_out_never
> +	 && (sysctl_tcp_cookie_size > 0
> +	  || (tp->cookie_values != NULL
> +	   && tp->cookie_values->cookie_desired > 0))) {

Likewise.

> +	/* Similar rationale to tcp_syn_options() applies here, too.
> +	 * If the <SYN> options fit, the same options should fit now!
> +	 */
> +	if (*md5 == NULL
> +	 && doing_ts
> +	 && cookie_plus > TCPOLEN_COOKIE_BASE) {

Likewise.

> +		if (cvp != NULL
> +		 && cvp->s_data_constant
> +		 && cvp->s_data_desired > 0) {

Likewise.

> +	if (tmp_opt.cookie_plus > 0
> +	 && tmp_opt.saw_tstamp
> +	 && !tp->rx_opt.cookie_out_never
> +	 && (sysctl_tcp_cookie_size > 0
> +	  || (tp->cookie_values != NULL
> +	   && tp->cookie_values->cookie_desired > 0))) {

Likewise.

Thanks.
