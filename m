From: Amit Salecha <amit.salecha@qlogic.com>
Subject: RE: [PATCH] qlcnic: fix panic on load
Date: Sun, 31 Oct 2010 23:58:29 -0500
Message-ID: <99737F4847ED0A48AECC9F4A1974A4B80FCEAB434D@MNEXMB2.qlogic.org>
References: <1288540238.2660.50.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexcashub1.qlogic.com ([198.70.193.61]:58273 "EHLO
	avexcashub1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752152Ab0KAE72 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Nov 2010 00:59:28 -0400
In-Reply-To: <1288540238.2660.50.camel@edumazet-laptop>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: Eric Dumazet [eric.dumazet@gmail.com]
> Sent: Sunday, October 31, 2010 9:20 PM
> To: David Miller
> Cc: netdev; Amit Salecha
> Subject: [PATCH] qlcnic: fix panic on load
> 
> Its now illegal to call netif_stop_queue() before register_netdev()
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> Cc: Amit Kumar Salecha <amit.salecha@qlogic.com>
> ---
> drivers/net/qlcnic/qlcnic_main.c |    1 -
> 1 file changed, 1 deletion(-)

Thanks Eric.