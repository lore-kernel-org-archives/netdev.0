From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] sctp: fix GSO for IPv6
Date: Sat, 16 Jul 2016 22:02:36 -0700 (PDT)
Message-ID: <20160716.220236.1000782551064979182.davem@davemloft.net>
References: <cc3fc851d2ff9abfe104807381cc21280648410d.1468609983.git.marcelo.leitner@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nhorman@tuxdriver.com, vyasevich@gmail.com,
	linux-sctp@vger.kernel.org
To: marcelo.leitner@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:45166 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751195AbcGQFCh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Jul 2016 01:02:37 -0400
In-Reply-To: <cc3fc851d2ff9abfe104807381cc21280648410d.1468609983.git.marcelo.leitner@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Date: Fri, 15 Jul 2016 16:40:02 -0300

> commit 90017accff61 ("sctp: Add GSO support") didn't register SCTP GSO
> offloading for IPv6 and yet didn't put any restrictions on generating
> GSO packets while in IPv6, which causes all IPv6 GSO'ed packets to be
> silently dropped.
> 
> The fix is to properly register the offload this time.
> 
> Fixes: 90017accff61 ("sctp: Add GSO support")
> Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>

Applied.
