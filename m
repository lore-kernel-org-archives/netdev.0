From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH v7 5/7 RFC] TCPCT part 1e: implement
 socket option TCP_COOKIE_TRANSACTIONS
Date: Fri, 20 Nov 2009 09:26:51 -0800 (PST)
Message-ID: <20091120.092651.254794724.davem@davemloft.net>
References: <4B06A1FF.8000202@gmail.com>
	<4B06AC2C.3070102@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: william.allen.simpson@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33044
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754571AbZKTR0e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Nov 2009 12:26:34 -0500
In-Reply-To: <4B06AC2C.3070102@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: William Allen Simpson <william.allen.simpson@gmail.com>
Date: Fri, 20 Nov 2009 09:48:12 -0500

> +		if (ctd.tcpct_used > sizeof(ctd.tcpct_value)
> +		 || ctd.tcpct_s_data_desired > TCP_MSS_DESIRED)
> +			return -EINVAL;

Please fix this conditional coding style.

> +		} else if ((0x1 & ctd.tcpct_cookie_desired)
> +			|| ctd.tcpct_cookie_desired > TCP_COOKIE_MAX
> +			|| ctd.tcpct_cookie_desired < TCP_COOKIE_MIN) {
> +			return -EINVAL;

Same here.

> +		if (ctd.tcpct_used > 0
> +		 || (tp->cookie_values == NULL
> +		  && (sysctl_tcp_cookie_size > 0
> +		   || ctd.tcpct_cookie_desired > 0
> +		   || ctd.tcpct_s_data_desired > 0))) {

Please fix the conditional coding style, and the alignment of
the lines, it's not right here.

> +		ctd.tcpct_flags = (tp->rx_opt.cookie_in_always
> +				   ? TCP_COOKIE_IN_ALWAYS : 0)
> +				| (tp->rx_opt.cookie_out_never
> +				   ? TCP_COOKIE_OUT_NEVER : 0);

"?" should be at end of previous line not at beginning of
next one, please fix this up.

Thanks.
