From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH v7 6/7 RFC] TCPCT part 1f: Initiator
 Cookie => Responder
Date: Fri, 20 Nov 2009 09:29:30 -0800 (PST)
Message-ID: <20091120.092930.128953283.davem@davemloft.net>
References: <4B06A1FF.8000202@gmail.com>
	<4B06ADF1.2010107@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: william.allen.simpson@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37722
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753595AbZKTR3M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Nov 2009 12:29:12 -0500
In-Reply-To: <4B06ADF1.2010107@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: William Allen Simpson <william.allen.simpson@gmail.com>
Date: Fri, 20 Nov 2009 09:55:45 -0500

> +	u8 cookie_size = (!tp->rx_opt.cookie_out_never && cvp != NULL)
> +			 ? tcp_cookie_size_check(cvp->cookie_desired)
> +			 : 0;

Please put the "?" and ":" and the end of the previous line not
at the beginning of the next one.
>  
> +	if (*md5 == NULL
> +	 && (OPTION_TS & opts->options)
> +	 && cookie_size > 0) {

Please fix up the coding style of this conditional.  The '&&'
belongs at the end of the previous line and the indentation is
not correct here.

Thanks.
