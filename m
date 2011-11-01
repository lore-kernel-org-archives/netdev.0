From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] IPv6 - support for NLM_F_* flags at IPv6 routing
 requests
Date: Tue, 1 Nov 2011 22:43:02 +0100
Message-ID: <20111101224302.6d370068@s6510.linuxnetplumber.net>
References: <1320157347.11816.3.camel@lakki>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Matti Vaittinen <matti.vaittinen@nsn.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:50305 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752553Ab1KAVnL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Nov 2011 17:43:11 -0400
In-Reply-To: <1320157347.11816.3.camel@lakki>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 01 Nov 2011 16:22:27 +0200
Matti Vaittinen <matti.vaittinen@nsn.com> wrote:

>  
> +#define RT6_CANT_CREATE ((int)-1)
>  #define RT6_DEBUG 2

Rather than introduce a new error flag, why not convert the code
to use the kernel standard PTR_ERR() macros?
