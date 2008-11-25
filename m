From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH -next/-mm/mainline] net/hp-plus: fix link errors
Date: Tue, 25 Nov 2008 18:18:00 +0000
Message-ID: <20081125181800.7502d395@lxorguk.ukuu.org.uk>
References: <20081120211724.09b94026.randy.dunlap@oracle.com>
	<20081121.163335.255948683.davem@davemloft.net>
	<20081125095952.f25e8286.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	jgarzik@pobox.com, akpm@linux-foundation.org
To: Randy Dunlap <randy.dunlap@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from earthlight.etchedpixels.co.uk ([81.2.110.250]:36926 "EHLO
	lxorguk.ukuu.org.uk" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752317AbYKYST3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2008 13:19:29 -0500
In-Reply-To: <20081125095952.f25e8286.randy.dunlap@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> WARNING: drivers/net/8390p: 'ei_set_multicast_list' exported twice. Previous export was in drivers/net/8390.ko
> WARNING: drivers/net/8390p: 'ei_get_stats' exported twice. Previous export was in drivers/net/8390.ko
> WARNING: drivers/net/8390p: 'ei_start_xmit' exported twice. Previous export was in drivers/net/8390.ko
> WARNING: drivers/net/8390p: 'ei_tx_timeout' exported twice. Previous export was in drivers/net/8390.ko

bash-3.2$ grep ei_set_multicast drivers/net/*c
bash-3.2$ grep ei_set_multicast  drivers/net/*h
bash-3.2$ grep ei_set_multicast  include/linux/*h
bash-3.2$ 

bash-3.2$ nm drivers/net/*o|grep ei_set_mu
nm: Warning: 'drivers/net/chelsio' is not an ordinary file
nm: Warning: 'drivers/net/hamradio' is not an ordinary file


Confused of South Wales

