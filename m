From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] atl1: fix oops when changing tx/rx ring params
Date: Fri, 31 Dec 2010 12:08:31 -0800 (PST)
Message-ID: <20101231.120831.232749764.davem@davemloft.net>
References: <20101227095402.76f98027@osprey.hogchain.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jussuf@linux.ee, kronos.it@gmail.com, chris.snook@gmail.com,
	netdev@vger.kernel.org, Xiong.Huang@Atheros.com, stable@kernel.org
To: jcliburn@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60075
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753939Ab0LaUIA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Dec 2010 15:08:00 -0500
In-Reply-To: <20101227095402.76f98027@osprey.hogchain.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "J. K. Cliburn" <jcliburn@gmail.com>
Date: Mon, 27 Dec 2010 09:54:02 -0600

> @@ -3544,11 +3546,20 @@ static int atl1_set_ringparam(struct net_device *netdev,
>  		adapter->rrd_ring = rrd_old;
>  		adapter->tpd_ring = tpd_old;
>  		adapter->ring_header = rhdr_old;
> +		/*
> + 		 * Save SMB and CMB, since atl1_free_ring_resources
> + 		 * will clear them as a result of commit
> + 		 * 3f5a2a713aad28480d86b0add00c68484b54febc
> + 		 */

Please do not reference commit IDs in code comments.

Thank you.
