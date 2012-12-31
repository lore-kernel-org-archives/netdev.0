From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RFC 15/15] via-rhine: add helper (reduce type-unsafe
 void * assignments).
Date: Mon, 31 Dec 2012 14:21:24 -0800 (PST)
Message-ID: <20121231.142124.257039279927120043.davem@davemloft.net>
References: <1356967549-5056-1-git-send-email-andi@lisas.de>
	<1356967549-5056-16-git-send-email-andi@lisas.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andim2@users.sf.net, rl@hellgate.ch, netdev@vger.kernel.org,
	romieu@fr.zoreil.com
To: andi@lisas.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54715 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751930Ab2LaWV0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Dec 2012 17:21:26 -0500
In-Reply-To: <1356967549-5056-16-git-send-email-andi@lisas.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andreas Mohr <andi@lisas.de>
Date: Mon, 31 Dec 2012 16:25:49 +0100

> From: Andreas Mohr <andim2@users.sf.net>
> 
> Signed-off-by: Andreas Mohr <andim2@users.sf.net>

This is of zero value.

It is just as likely one would forget to use the helper as it would be
to assign pci_get_drvdata() to a pointer of the wrong type.
