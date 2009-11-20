From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH v7 3/7 RFC] TCPCT part 1c:
 sysctl_tcp_cookie_size, socket option TCP_COOKIE_TRANSACTIONS
Date: Fri, 20 Nov 2009 09:24:08 -0800 (PST)
Message-ID: <20091120.092408.208010931.davem@davemloft.net>
References: <4B06A1FF.8000202@gmail.com>
	<4B06A8CF.3000303@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: william.allen.simpson@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33038
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753392AbZKTRXv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Nov 2009 12:23:51 -0500
In-Reply-To: <4B06A8CF.3000303@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: William Allen Simpson <william.allen.simpson@gmail.com>
Date: Fri, 20 Nov 2009 09:33:51 -0500

> @@ -59,6 +59,14 @@ int sysctl_tcp_base_mss __read_mostly = 512;
>  /* By default, RFC2861 behavior.  */
>  int sysctl_tcp_slow_start_after_idle __read_mostly = 1;
>  
> +#ifdef CONFIG_SYSCTL
> +/* By default, let the user enable it. */
> +int sysctl_tcp_cookie_size __read_mostly = 0;
> +#else
> +int sysctl_tcp_cookie_size __read_mostly = TCP_COOKIE_MAX;
> +#endif
> +

I would prefer if the default did not depend upon whether
SYSCTL is enabled or not.  That's extremely non-intuitive.

