From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] inetpeer: Support ipv6 addresses.
Date: Mon, 29 Nov 2010 19:18:22 -0800 (PST)
Message-ID: <20101129.191822.226761971.davem@davemloft.net>
References: <20101129.134403.179947389.davem@davemloft.net>
	<20101129143357.3dfb2efe@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47819
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752215Ab0K3DR4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Nov 2010 22:17:56 -0500
In-Reply-To: <20101129143357.3dfb2efe@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Mon, 29 Nov 2010 14:33:57 -0800

> On Mon, 29 Nov 2010 13:44:03 -0800 (PST)
> David Miller <davem@davemloft.net> wrote:
> 
>> +static inline bool inet_peer_addr_equal(inet_peer_address_t *a, inet_peer_address_t *b)
> 
> Let the compiler decide about inline.
> Should be const inet_peer_address_t *

Yep, I made those changes thanks.
