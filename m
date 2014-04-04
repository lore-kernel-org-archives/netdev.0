From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH] veth: keep peers MTU values synchronized
Date: Fri, 04 Apr 2014 10:49:21 -0400 (EDT)
Message-ID: <20140404.104921.1668611243816621886.davem@davemloft.net>
References: <533DD390.6020103@gmail.com>
	<20140404.102518.2263545144702348056.davem@davemloft.net>
	<533EC4D5.50304@securitycode.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: matvejchikov@gmail.com, netdev@vger.kernel.org
To: i.matveychikov@securitycode.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52156 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753286AbaDDOrq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Apr 2014 10:47:46 -0400
In-Reply-To: <533EC4D5.50304@securitycode.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Ilya V. Matveychikov" <i.matveychikov@securitycode.ru>
Date: Fri, 4 Apr 2014 18:42:29 +0400

> Peers are created at once and ether_setup used for the configuration so MTU
> values equals.

If an IFLA_MTU value is specified for the peer it will be honored.
