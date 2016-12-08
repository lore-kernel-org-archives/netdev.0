From: David Miller <davem@davemloft.net>
Subject: Re: [patch] ser_gigaset: return -ENOMEM on error instead of success
Date: Thu, 08 Dec 2016 14:19:50 -0500 (EST)
Message-ID: <20161208.141950.834129897171154805.davem@davemloft.net>
References: <20161207112203.GC5507@elgon.mountain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pebolle@tiscali.nl, tilman@imap.cc, isdn@linux-pingi.de,
        gigaset307x-common@lists.sourceforge.net, netdev@vger.kernel.org,
        kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:37194 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753157AbcLHTTw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Dec 2016 14:19:52 -0500
In-Reply-To: <20161207112203.GC5507@elgon.mountain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Wed, 7 Dec 2016 14:22:03 +0300

> If we can't allocate the resources in gigaset_initdriver() then we
> should return -ENOMEM instead of zero.
> 
> Fixes: 2869b23e4b95 ("[PATCH] drivers/isdn/gigaset: new M101 driver (v2)")
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied and queued up for -stable, thanks.
