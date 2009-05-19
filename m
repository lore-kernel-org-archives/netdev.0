From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] TX_RING and packet mmap
Date: Mon, 18 May 2009 22:12:38 -0700 (PDT)
Message-ID: <20090518.221238.253830855.davem@davemloft.net>
References: <1242076914.12380.2.camel@bender>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, herbert@gondor.apana.org.au,
	kaber@trash.net, hadi@cyberus.ca, cl@linux.com, zbr@ioremap.net
To: johann.baudy@gnu-log.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42292
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753479AbZESFMl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 May 2009 01:12:41 -0400
In-Reply-To: <1242076914.12380.2.camel@bender>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johann Baudy <johann.baudy@gnu-log.net>
Date: Mon, 11 May 2009 23:21:54 +0200

> New packet socket feature that makes packet socket more efficient for transmission.
> - It reduces number of system call through a PACKET_TX_RING mechanism, based on PACKET_RX_RING (Circular buffer allocated in kernel space which is mmapped from user space).
> - It minimizes CPU copy using fragmented SKB (almost zero copy).
> 
> Signed-off-by: Johann Baudy <johann.baudy@gnu-log.net>

Applied, thanks.
