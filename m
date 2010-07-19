From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] s2io: Remove unnecessary memset of netdev private data
Date: Mon, 19 Jul 2010 09:28:20 -0700 (PDT)
Message-ID: <20100719.092820.24567424.davem@davemloft.net>
References: <1279529758-7901-1-git-send-email-tklauser@distanz.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: tklauser@distanz.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54554
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S936389Ab0GSQ2E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Jul 2010 12:28:04 -0400
In-Reply-To: <1279529758-7901-1-git-send-email-tklauser@distanz.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tobias Klauser <tklauser@distanz.ch>
Date: Mon, 19 Jul 2010 10:55:58 +0200

> The memory for the private data is allocated using kzalloc in
> alloc_etherdev (or alloc_netdev_mq respectively) so there is no need to
> set it to 0 again.
> 
> Signed-off-by: Tobias Klauser <tklauser@distanz.ch>

Applied, thanks.
