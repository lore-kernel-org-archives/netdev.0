From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] pch_gbe: fix error handling in pch_gbe_up()
Date: Wed, 24 Oct 2012 23:04:44 -0400 (EDT)
Message-ID: <20121024.230444.2208622837386479403.davem@davemloft.net>
References: <1351004074-10225-1-git-send-email-vfalico@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, richardcochran@gmail.com,
	tshimizu818@gmail.com, andy.cress@us.kontron.com,
	erwan.velu@zodiacaerospace.com
To: vfalico@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59879 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757394Ab2JYDEs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Oct 2012 23:04:48 -0400
In-Reply-To: <1351004074-10225-1-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Veaceslav Falico <vfalico@redhat.com>
Date: Tue, 23 Oct 2012 16:54:34 +0200

> If we fail to allocate rx buffers pool by any reason, we'll just return
> with an error, however we've previously successfully requested an irq. Fix
> this by releasing the irq before returning the error.
> 
> Signed-off-by: Veaceslav Falico <vfalico@redhat.com>

Applied, thanks.
