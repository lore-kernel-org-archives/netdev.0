From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] greth: Remove unnecessary memset of napi member in
 netdev private data
Date: Mon, 07 Jun 2010 01:21:00 -0700 (PDT)
Message-ID: <20100607.012100.184823605.davem@davemloft.net>
References: <1275632661-16406-1-git-send-email-tklauser@distanz.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kristoffer@gaisler.com, netdev@vger.kernel.org
To: tklauser@distanz.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54674
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756508Ab0FGIUw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jun 2010 04:20:52 -0400
In-Reply-To: <1275632661-16406-1-git-send-email-tklauser@distanz.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tobias Klauser <tklauser@distanz.ch>
Date: Fri,  4 Jun 2010 08:24:21 +0200

> The memory for the private data is allocated using kzalloc in
> alloc_etherdev (or alloc_netdev_mq respectively) so there is no need to
> set the napi member to 0 explicitely.
> 
> Signed-off-by: Tobias Klauser <tklauser@distanz.ch>

Applied.
