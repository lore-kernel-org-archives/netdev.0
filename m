From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [XFRM] Fix unexpected SA hard expiration after
 changing date
Date: Thu, 02 Aug 2012 00:21:00 -0700 (PDT)
Message-ID: <20120802.002100.1997441066753440100.davem@davemloft.net>
References: <1343720634-1176-1-git-send-email-fdu@windriver.com>
	<1343720634-1176-2-git-send-email-fdu@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.hengli.com.au, netdev@vger.kernel.org
To: fdu@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53137 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750775Ab2HBHVA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Aug 2012 03:21:00 -0400
In-Reply-To: <1343720634-1176-2-git-send-email-fdu@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fan Du <fdu@windriver.com>
Date: Tue, 31 Jul 2012 15:43:54 +0800

> After SA is setup, one timer is armed to detect soft/hard expiration,
> however the timer handler uses xtime to do the math. This makes hard
> expiration occurs first before soft expiration after setting new date
> with big interval. As a result new child SA is deleted before rekeying
> the new one.
> 
> Signed-off-by: Fan Du <fdu@windriver.com>

Applied.
