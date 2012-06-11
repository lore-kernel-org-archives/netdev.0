From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv4: Add interface option to enable routing
 of 127.0.0.0/8
Date: Mon, 11 Jun 2012 16:57:40 -0700 (PDT)
Message-ID: <20120611.165740.419299184892679723.davem@davemloft.net>
References: <20120608101859.GH32152@canuck.infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: tgraf@suug.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47041 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752702Ab2FKX5l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jun 2012 19:57:41 -0400
In-Reply-To: <20120608101859.GH32152@canuck.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Graf <tgraf@suug.ch>
Date: Fri, 8 Jun 2012 06:18:59 -0400

> -		if (i == IPV4_DEVCONF_ACCEPT_LOCAL - 1)
> +		if (i == IPV4_DEVCONF_ACCEPT_LOCAL - 1 ||
> +		    i == IPV4_DEVCONF_ROUTE_LOCALNET)

Why does one value get tested using "X - 1" indexing and the
other gets tested using plain "X" indexing?
