From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Make udp_encap_rcv use pskb_may_pull
Date: Wed, 22 Nov 2006 20:11:36 -0800 (PST)
Message-ID: <20061122.201136.129449260.davem@davemloft.net>
References: <20061123000144.GB7452@suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39552
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1755796AbWKWELd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Nov 2006 23:11:33 -0500
To: okir@suse.de
In-Reply-To: <20061123000144.GB7452@suse.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Olaf Kirch <okir@suse.de>
Date: Thu, 23 Nov 2006 01:01:44 +0100

> 
> Make udp_encap_rcv use pskb_may_pull
> 
> IPsec with NAT-T breaks on some notebooks using the latest e1000 chipset,
> when header split is enabled. When receiving sufficiently large packets, the
> driver puts everything up to and including the UDP header into the header
> portion of the skb, and the rest goes into the paged part. udp_encap_rcv
> forgets to use pskb_may_pull, and fails to decapsulate it. Instead, it
> passes it up it to the IKE daemon.
> 
> Signed-off-by: Olaf Kirch <okir@suse.de>
> Signed-off-by: Jean Delvare <jdelvare@suse.de>

Excellent catch, applied, thanks Olaf.
