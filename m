From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/9] sfc: support for cascaded multicast
 filtering
Date: Tue, 21 Jul 2015 22:21:49 -0700 (PDT)
Message-ID: <20150721.222149.1949874133910212214.davem@davemloft.net>
References: <55AE5230.3040605@solarflare.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: ecree@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36744 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932093AbbGVFVu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jul 2015 01:21:50 -0400
In-Reply-To: <55AE5230.3040605@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Edward Cree <ecree@solarflare.com>
Date: Tue, 21 Jul 2015 15:07:44 +0100

> Recent versions of firmware for SFC9100 adapters add support for filter
>  chaining, in which packets matching multiple filters are delivered to all
>  filters' recipients, rather than only the highest match-priority filter as was
>  previously the case.
> This patch series enables this feature and redesigns the filter handling code
>  to make use of it; in particular, subscribing to a multicast address on one
>  function no longer prevents traffic to that address reaching another function
>  which is in promiscuous or allmulti mode.
> If the firmware does not support filter chaining, the driver will fall back to
>  the old behaviour.

Series applied, thanks.
