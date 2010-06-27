From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ISDN: hysdn, fix potential NULL dereference
Date: Sat, 26 Jun 2010 22:12:53 -0700 (PDT)
Message-ID: <20100626.221253.85403037.davem@davemloft.net>
References: <1277206896-27197-1-git-send-email-jslaby@suse.cz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: isdn@linux-pingi.de, linux-kernel@vger.kernel.org,
	jirislaby@gmail.com, shemminger@vyatta.com, kaber@trash.net,
	netdev@vger.kernel.org
To: jslaby@suse.cz
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60433
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751495Ab0F0FMk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Jun 2010 01:12:40 -0400
In-Reply-To: <1277206896-27197-1-git-send-email-jslaby@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Slaby <jslaby@suse.cz>
Date: Tue, 22 Jun 2010 13:41:36 +0200

> Stanse found that lp is dereferenced earlier than checked for being
> NULL in hysdn_rx_netpkt. Move the initialization below the test.
> 
> Signed-off-by: Jiri Slaby <jslaby@suse.cz>

Applied.
