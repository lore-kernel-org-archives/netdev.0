From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH v7 1/7 RFC] TCPCT part 1a: add
 request_values parameter for sending SYNACK
Date: Fri, 20 Nov 2009 09:20:17 -0800 (PST)
Message-ID: <20091120.092017.54863878.davem@davemloft.net>
References: <4B06A1FF.8000202@gmail.com>
	<4B06A3BD.8090804@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: william.allen.simpson@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41323
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753464AbZKTRUA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Nov 2009 12:20:00 -0500
In-Reply-To: <4B06A3BD.8090804@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: William Allen Simpson <william.allen.simpson@gmail.com>
Date: Fri, 20 Nov 2009 09:12:13 -0500

> -	if (tcp_v6_send_synack(sk, req))
> -		goto drop;
> +	if (tcp_v6_send_synack(sk, req, NULL)
> +	 || want_cookie)
> +		goto drop_and_free;

Please fix the coding style here, the "||" belongs at the end
of the previous line, not at the start of the next one.

Also, since it will all fit one one line anyways, please make
it that way:

	if (tcp_v6_send_synack(sk, req, NULL) || want_cookie)

Some of us still use 80x25 terminals to read code :-)

I think you've been asked to fix this specific kinds of cases up
before.

Thanks a lot.
