From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] farsync: add module_put to error path in fst_open()
Date: Fri, 17 Jun 2011 15:28:05 -0400 (EDT)
Message-ID: <20110617.152805.824692696209804231.davem@davemloft.net>
References: <1308327913-23220-1-git-send-email-shved@ispras.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kevin.curtis@farsite.co.uk, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, ldv-project@ispras.ru
To: shved@ispras.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:47527 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932429Ab1FQT2Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jun 2011 15:28:24 -0400
In-Reply-To: <1308327913-23220-1-git-send-email-shved@ispras.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Shved <shved@ispras.ru>
Date: Fri, 17 Jun 2011 20:25:10 +0400

> The fst_open() function, after a successful try_module_get() may return
> an error code if hdlc_open() returns it.  However, it does not put the
> module on this error path.
> 
> This patch adds the necessary module_put() call.
> 
> Found by Linux Driver Verification project (linuxtesting.org).
> 
> Signed-off-by: Pavel Shved <shved@ispras.ru>

Applied.
