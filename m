From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 1/3] inetpeer: Support ipv6 addresses.
Date: Mon, 29 Nov 2010 14:33:57 -0800
Message-ID: <20101129143357.3dfb2efe@nehalam>
References: <20101129.134403.179947389.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:42336 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754709Ab0K2Wd7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Nov 2010 17:33:59 -0500
In-Reply-To: <20101129.134403.179947389.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 29 Nov 2010 13:44:03 -0800 (PST)
David Miller <davem@davemloft.net> wrote:

> +static inline bool inet_peer_addr_equal(inet_peer_address_t *a, inet_peer_address_t *b)

Let the compiler decide about inline.
Should be const inet_peer_address_t *


-- 
