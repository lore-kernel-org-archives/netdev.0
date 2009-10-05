From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] TCPCT+1: initial SYN exchange with SYNACK data
Date: Mon, 05 Oct 2009 00:27:19 -0700 (PDT)
Message-ID: <20091005.002719.146534039.davem@davemloft.net>
References: <4AC79905.1030904@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: william.allen.simpson@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58644
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758541AbZJEH1Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Oct 2009 03:27:25 -0400
In-Reply-To: <4AC79905.1030904@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: William Allen Simpson <william.allen.simpson@gmail.com>
Date: Sat, 03 Oct 2009 14:33:41 -0400

> @@ -406,6 +454,32 @@ struct tcp_sock {
 ...
> +	struct tcp_s_data_payload	*s_data_payload;
 ...
> +	struct tcp_cookie_pair	  	*cookie_pair;
 ...
> +	u16				s_data_desired;	/* bytes */
 ...
> +	u8				cookie_desired;	/* bytes */
> +	u8				s_data_in:1,
> +					s_data_out:1,
> +					cookie_in_always:1,
> +					cookie_out_never:1;

struct tcp_sock is already WAY TOO BIG on 64-bit systems, adding 20
more bytes to it for some odd-ball feature is not something I'm
willing to do, sorry.
