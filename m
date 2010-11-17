From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] gianfar: fix signedness issue
Date: Wed, 17 Nov 2010 12:40:43 -0800 (PST)
Message-ID: <20101117.124043.52191671.davem@davemloft.net>
References: <20101115215942.354b0394@absol.kitzblitz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: galak@kernel.crashing.org, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: nikai@nikai.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54298
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932364Ab0KQUkS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Nov 2010 15:40:18 -0500
In-Reply-To: <20101115215942.354b0394@absol.kitzblitz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Kaiser <nikai@nikai.net>
Date: Mon, 15 Nov 2010 21:59:42 +0100

> irq_of_parse_and_map() has an unsigned return type.
> Testing for a negative error value doesn't work here.
> 
> Signed-off-by: Nicolas Kaiser <nikai@nikai.net>
> ---
> I see that in numerous places the return value is tested
> for NO_IRQ. I hope it's the right thing to do here as well?

I think it is, applied, thank you.
