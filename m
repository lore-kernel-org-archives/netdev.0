From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] drivers/s390/ - csum_partial - remove unnecessary
 casts
Date: Wed, 19 Nov 2008 15:45:21 -0800 (PST)
Message-ID: <20081119.154521.31283668.davem@davemloft.net>
References: <1226944512-13310-1-git-send-email-joe@perches.com>
	<1226944512-13310-3-git-send-email-joe@perches.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, frank.blaschka@de.ibm.com, jeff@garzik.org
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59420
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752033AbYKSXpV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Nov 2008 18:45:21 -0500
In-Reply-To: <1226944512-13310-3-git-send-email-joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>
Date: Mon, 17 Nov 2008 09:55:12 -0800

>     The first argument to csum_partial is const void *
>     casts to char/u8 * are not necessary
> 
> Signed-off-by: Joe Perches <joe@perches.com>

Applied.
