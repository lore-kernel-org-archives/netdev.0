From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/8] 3c507: Remove unnecessary memset of netdev private
 data
Date: Thu, 06 May 2010 22:11:13 -0700 (PDT)
Message-ID: <20100506.221113.63031039.davem@davemloft.net>
References: <1273160351-12710-1-git-send-email-tklauser@distanz.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: tklauser@distanz.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49429
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751618Ab0EGFLG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 May 2010 01:11:06 -0400
In-Reply-To: <1273160351-12710-1-git-send-email-tklauser@distanz.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tobias Klauser <tklauser@distanz.ch>
Date: Thu,  6 May 2010 17:39:11 +0200

> The memory for the private data is allocated using kzalloc in
> alloc_etherdev (or alloc_netdev_mq respectively) so there is no need to
> set it to 0 again.
> 
> Signed-off-by: Tobias Klauser <tklauser@distanz.ch>

Applied.
