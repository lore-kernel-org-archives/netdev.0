From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next 2/9] gue: Support for Generic UDP Encapsulation
 RX path
Date: Thu, 24 Jul 2014 08:13:12 -0700
Message-ID: <20140724081312.46b533c7@haswell.linuxnetplumber.net>
References: <alpine.DEB.2.02.1407162058200.2128@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:38015 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759076AbaGXPNL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jul 2014 11:13:11 -0400
Received: by mail-pa0-f45.google.com with SMTP id eu11so4099015pac.4
        for <netdev@vger.kernel.org>; Thu, 24 Jul 2014 08:13:10 -0700 (PDT)
In-Reply-To: <alpine.DEB.2.02.1407162058200.2128@tomh.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 16 Jul 2014 21:14:30 -0700 (PDT)
Tom Herbert <therbert@google.com> wrote:

> +
> +#define open_gue_port(proto)					\
> +	(gue_udp_port ?						\
> +	 gue_open_direct_port(gue_udp_port, proto, &gue_sock) :	\
> +	 0)
> +
> +#define close_gue_port() do {					\
> +	if (gue_sock) {						\
> +		gue_close_port(gue_sock);			\
> +		gue_sock = NULL;				\
> +	}							\
> +} while (0)

Macro;s are evil and unnecessary for this.
