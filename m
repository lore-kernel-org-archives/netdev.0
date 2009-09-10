From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] dm9000: Remove unnecessary memset of netdev private
 data
Date: Wed, 09 Sep 2009 18:55:19 -0700 (PDT)
Message-ID: <20090909.185519.108860491.davem@davemloft.net>
References: <1252494464-4633-1-git-send-email-tklauser@distanz.ch>
	<1252494464-4633-2-git-send-email-tklauser@distanz.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: tklauser@distanz.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43355
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754912AbZIJBzD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Sep 2009 21:55:03 -0400
In-Reply-To: <1252494464-4633-2-git-send-email-tklauser@distanz.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tobias Klauser <tklauser@distanz.ch>
Date: Wed,  9 Sep 2009 13:07:44 +0200

> The memory for the private data is allocated using kzalloc in
> alloc_etherdev (or alloc_netdev_mq respectively) so there is no need to
> set it to 0 again.
> 
> Signed-off-by: Tobias Klauser <tklauser@distanz.ch>

Applied.
